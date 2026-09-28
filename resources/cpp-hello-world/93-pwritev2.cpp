#include <iterator>
#include <sys/uio.h>
#include <unistd.h>

int main()
{
    char hello[] = "Hello ";
    char world[] = "World\n";
    iovec iov[] = {
        { hello, sizeof(hello) - 1 },
        { world, sizeof(world) - 1 },
    };
    // offset -1 => write at the current file offset, like writev(),
    // so it works on non-seekable fds (terminal, pipe) too.
    pwritev2(STDOUT_FILENO, iov, std::size(iov), -1, 0);
}
