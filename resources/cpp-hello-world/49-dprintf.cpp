#include <cstdio>
#include <unistd.h>

int main()
{
    dprintf(STDOUT_FILENO, "Hello World\n");
}
