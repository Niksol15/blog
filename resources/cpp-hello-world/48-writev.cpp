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
    writev(STDOUT_FILENO, iov, std::size(iov));
}
