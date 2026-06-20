#include <sys/wait.h>
#include <unistd.h>

int main()
{
    if (fork() == 0)
    {
        char arg0[] = "echo";
        char arg1[] = "Hello World";
        char* args[] = { arg0, arg1, nullptr };
        execvp("echo", args);
        _exit(127);  // only reached if exec failed
    }
    wait(nullptr);
}
