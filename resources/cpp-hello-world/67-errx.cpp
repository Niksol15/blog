#include <err.h>

int main()
{
    // errx() = err() without the strerror(errno) suffix; still exits.
    errx(1, "Hello World");   // "<progname>: Hello World" to stderr, then exit(1)
}
