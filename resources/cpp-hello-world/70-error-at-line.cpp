#include <error.h>

int main()
{
    // Like error(), but also prints a file:line prefix — meant for compilers/parsers.
    error_at_line(0, 0, "input", 1, "Hello World");
    // "<progname>:input:1: Hello World" to stderr
}
