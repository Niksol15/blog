#include <error.h>

int main()
{
    // glibc's <error.h> (GNU, not BSD <err.h>): status 0 = do not exit, errnum 0 = no strerror.
    error(0, 0, "Hello World");   // "<progname>: Hello World" to stderr
}
