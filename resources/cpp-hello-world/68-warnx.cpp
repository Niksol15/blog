#include <err.h>

int main()
{
    // warnx() = the cleanest of the four: no errno suffix, no exit.
    warnx("Hello World");   // "<progname>: Hello World" to stderr
}
