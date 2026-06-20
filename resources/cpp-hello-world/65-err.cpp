#include <cerrno>
#include <err.h>

int main()
{
    errno = 0;
    // err() = "<progname>: Hello World: <strerror(errno)>" to stderr, then exit(1).
    err(1, "Hello World");
}
