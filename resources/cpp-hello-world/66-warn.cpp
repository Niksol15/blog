#include <cerrno>
#include <err.h>

int main()
{
    errno = 0;
    // warn() = same as err(), but WITHOUT exiting.
    warn("Hello World");   // "<progname>: Hello World: Success" to stderr
}
