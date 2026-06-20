#!/usr/bin/env bash
# Compile and run every Hello World sample, checking that "Hello World" really
# appears (at runtime, or in the compiler diagnostic for the compile-time ones).
#
#   ./verify.sh         # check all methods
#   ./verify.sh 19      # check only method 19
#
# Requires: g++ with -std=c++26 (GCC 16+). io_uring also needs liburing-devel.
set -u
cd "$(dirname "$0")"
CXX=${CXX:-g++}
STD=-std=c++26
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

pass=0 fail=0 skip=0

link_flags() { case "$1" in aio|lio-listio) echo "-lrt";; io-uring) echo "-luring";; contract-assert|pre|post) echo "-fcontracts";; esac; }
# constexpr-throw needs GCC for the what() text; Clang only echoes the source line (still contains "Hello World").
# diagnose-if is the mirror image: Clang-only (GCC ignores the attribute), so it is forced through clang++ below.
# include-missing / asm-* emit the string from the preprocessor / assembler, not the compiler proper.
is_compile_time() { case "$1" in static-assert|static-assert-template|constexpr-throw|deprecated|delete|nodiscard|include-missing|pragma-message|warning|error|attribute-warning|attribute-error|attribute-unavailable|attribute-diagnose-if|asm-error|asm-warning|asm-print) return 0;; *) return 1;; esac; }

check() {
    local src="$1" num="${1%%-*}" name; name=$(basename "$src" .cpp); name=${name#*-}
    local lf; lf=$(link_flags "$name")
    local opt=-O2; [ "$name" = attribute-warning ] && opt=-O0  # call must survive to be diagnosed

    # diagnose-if only fires on Clang; everything else uses the configured $CXX.
    local cc=$CXX
    if [ "$name" = attribute-diagnose-if ]; then
        if ! command -v clang++ >/dev/null; then echo "  skip $src (needs clang++)"; skip=$((skip+1)); return; fi
        cc=clang++
    fi
    # C++26 Contracts are GCC-only so far (Clang 22 has no -fcontracts); force g++.
    case "$name" in contract-assert|pre|post)
        if ! command -v g++ >/dev/null; then echo "  skip $src (needs g++ for -fcontracts)"; skip=$((skip+1)); return; fi
        cc=g++;;
    esac

    if is_compile_time "$name"; then
        # success = the diagnostic mentions Hello World (errors are expected for some).
        # Capture stdout too: the assembler's .print directive writes to stdout, not stderr.
        if $cc $STD $opt -c "$src" -o /dev/null >"$TMP/d" 2>&1 ; :; grep -qi "hello world" "$TMP/d"; then
            echo "  ok   $src (compile-time diagnostic)"; pass=$((pass+1))
        else
            echo "  FAIL $src (no Hello World in diagnostic)"; fail=$((fail+1)); fi
        return
    fi

    if [ "$name" = io-uring ] && ! echo '#include <liburing.h>' | $CXX $STD -x c++ -E - >/dev/null 2>&1; then
        echo "  skip $src (liburing-devel not installed)"; skip=$((skip+1)); return; fi

    if ! $cc $STD $opt -Wall -Wextra "$src" -o "$TMP/bin" $lf 2>"$TMP/d"; then
        echo "  FAIL $src (compile error)"; sed 's/^/       /' "$TMP/d" | head -3; fail=$((fail+1)); return; fi

    local out
    if [ "$name" = dev-tty ]; then          # needs a controlling terminal
        out=$(python3 -c "import pty;pty.spawn(['$TMP/bin'])" 2>&1)
    else
        out=$("$TMP/bin" 2>&1)
    fi
    if echo "$out" | grep -q "Hello World"; then
        echo "  ok   $src"; pass=$((pass+1))
    else
        echo "  FAIL $src (ran but no Hello World: [$out])"; fail=$((fail+1)); fi
}

if [ $# -ge 1 ]; then
    for n in "$@"; do for f in "$n"-*.cpp; do check "$f"; done; done
else
    for f in [0-9][0-9]-*.cpp; do check "$f"; done
fi

echo "----"
echo "pass=$pass fail=$fail skip=$skip"
[ "$fail" -eq 0 ]
