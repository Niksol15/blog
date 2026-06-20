#!/usr/bin/env bash
# Reproduce the *technical claims* the article makes beyond "it prints Hello World":
#   - char-by-char output (put/putchar) coalesces into ONE write(2)
#   - cout / printf / write / syscall all bottom out in the same write(1, ..., 12)
#   - cerr vs clog buffering (default vs sync_with_stdio(false))
#   - uncaught throw byte counts in stderr
#   - __attribute__((warning)) fires at -O0 but is optimized away at -O2
#   - pwrite needs a seekable fd (works to a file, ESPIPE to a pipe/terminal)
#   - the "not counted" mentions (signal handler, dlsym) still bottom out in write/puts
#
# Builds into a temp dir (like verify.sh); nothing is left behind.
set -u
cd "$(dirname "$0")"
CXX=${CXX:-g++}
STD=-std=c++26
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

writes_to() {  # writes_to <fd> <binary> [args...] -> count of write(fd, ...) syscalls
    local fd="$1"; shift
    strace -f -o "$TMP/trace" -e trace=write "$@" >/dev/null 2>&1
    grep -c "write($fd," "$TMP/trace"
}

echo "=== A. char-by-char coalesces into one write ==="
$CXX $STD -O2 14-ostream-put.cpp -o "$TMP/put"
$CXX $STD -O2 17-putchar.cpp     -o "$TMP/putchar"
echo "  ostream::put  -> $(writes_to 1 "$TMP/put") write(1) syscall(s)"
echo "  putchar       -> $(writes_to 1 "$TMP/putchar") write(1) syscall(s)"

echo "=== F. all roads lead to write(fd, \"Hello World\\n\", 12) -- only the fd differs ==="
for m in 01-cout 02-printf 27-wcout 47-write 72-syscall 24-cerr 26-fprintf-stderr; do
    $CXX $STD -O2 "$m.cpp" -o "$TMP/bin"
    line=$(strace -o "$TMP/trace" -e write "$TMP/bin" >/dev/null 2>&1; grep -E 'write\([12],' "$TMP/trace" | grep -i hello | head -1)
    printf '  %-18s %s\n' "$m" "$line"
done

echo "=== B. cerr vs clog buffering ==="
cat > "$TMP/cerr.cpp"        <<'EOF'
#include <iostream>
int main() { std::cerr << "Hello" << " " << "World" << "\n"; }
EOF
cat > "$TMP/clog.cpp"        <<'EOF'
#include <iostream>
int main() { std::clog << "Hello" << " " << "World" << "\n"; }
EOF
cat > "$TMP/cerr-nosync.cpp" <<'EOF'
#include <iostream>
int main() { std::ios_base::sync_with_stdio(false); std::cerr << "Hello" << " " << "World" << "\n"; }
EOF
cat > "$TMP/clog-nosync.cpp" <<'EOF'
#include <iostream>
int main() { std::ios_base::sync_with_stdio(false); std::clog << "Hello" << " " << "World" << "\n"; }
EOF
for f in cerr clog cerr-nosync clog-nosync; do
    $CXX $STD -O2 "$TMP/$f.cpp" -o "$TMP/$f"
    printf '  %-12s -> %s write(2) syscall(s)\n' "$f" "$(writes_to 2 "$TMP/$f")"
done

echo "=== C. uncaught throw: byte counts in stderr ==="
$CXX $STD -O2 41-throw.cpp -o "$TMP/throw"
strace -o "$TMP/trace" -e write "$TMP/throw" >/dev/null 2>&1
grep 'write(2,' "$TMP/trace" | sed 's/^/  /'

echo "=== D. __attribute__((warning)) survives -O0, vanishes at -O2 ==="
for opt in -O0 -O2; do
    n=$($CXX $STD $opt -c 86-attribute-warning.cpp -o /dev/null 2>&1 | grep -c 'Hello World')
    echo "  $opt -> warning present: $([ "$n" -gt 0 ] && echo yes || echo no)"
done

echo "=== E. pwrite needs a seekable fd ==="
cat > "$TMP/pw.cpp" <<'EOF'
#include <cerrno>
#include <cstdio>
#include <cstring>
#include <unistd.h>
int main()
{
    ssize_t n = pwrite(STDOUT_FILENO, "Hello World\n", 12, 0);
    if (n < 0)
    {
        fprintf(stderr, "pwrite failed: %s", strerror(errno));
    }
    return 0;
}
EOF
$CXX $STD -O2 "$TMP/pw.cpp" -o "$TMP/pw"
"$TMP/pw" 2>"$TMP/err" | cat >/dev/null
echo "  to a pipe : [$(tr -d '\n' < "$TMP/err")]"
"$TMP/pw" > "$TMP/pw.out" 2>"$TMP/err"
echo "  to a file : wrote $(wc -c < "$TMP/pw.out") bytes, stderr=[$(tr -d '\n' < "$TMP/err")]"

echo "=== G. the 'not counted' mentions still bottom out in a counted method ==="
cat > "$TMP/signal.cpp" <<'EOF'
#include <csignal>
#include <unistd.h>
void handler(int)
{
    static constexpr char msg[] = "Hello World\n";
    write(STDOUT_FILENO, msg, sizeof(msg) - 1);   // identical to method #50
}
int main()
{
    signal(SIGUSR1, handler);
    raise(SIGUSR1);
}
EOF
cat > "$TMP/dlsym.cpp" <<'EOF'
#include <dlfcn.h>
int main()
{
    using puts_t = int (*)(const char*);
    auto fn = reinterpret_cast<puts_t>(dlsym(RTLD_DEFAULT, "puts"));
    fn("Hello World");                            // resolves and calls puts, method #4
}
EOF
$CXX $STD -O2 "$TMP/signal.cpp" -o "$TMP/signal"
$CXX $STD -O2 "$TMP/dlsym.cpp"  -o "$TMP/dlsym" -ldl
echo "  signal handler -> [$("$TMP/signal")] ($(writes_to 1 "$TMP/signal") write(1) syscall, same as #47)"
echo "  dlsym -> puts   -> [$("$TMP/dlsym")] (resolved at runtime, then it is just #4)"

echo "=== H. POSIX AIO (aio_write #54, lio_listio #55) still bottoms out in write(2) ==="
echo "    glibc runs the I/O on a helper thread; with a non-seekable stdout (pipe/tty, as in a"
echo "    real terminal) pwrite hits ESPIPE and the thread falls back to a plain write(1)."
for m in 54-aio 55-lio-listio; do
    $CXX $STD -O2 "$m.cpp" -o "$TMP/bin" -lrt
    # stdout -> pipe (to cat) makes fd 1 non-seekable, reproducing the terminal case
    strace -f -o "$TMP/trace" -e trace=write,pwrite64 "$TMP/bin" 2>/dev/null | cat >/dev/null
    printf '  %-14s ->\n' "$m"
    grep -iE 'pwrite64\(1,|write\(1,' "$TMP/trace" | grep -i hello | sed 's/^/      /'
done
