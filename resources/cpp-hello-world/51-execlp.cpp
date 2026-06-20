#include <unistd.h>

int main()
{
    execlp("echo", "echo", "Hello World", static_cast<char*>(nullptr));
}
