#include <cerrno>
#include <cstdio>

int main()
{
    errno = 0;
    perror("Hello World");
}
