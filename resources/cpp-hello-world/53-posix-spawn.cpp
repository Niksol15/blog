#include <spawn.h>
#include <sys/wait.h>

extern char** environ;

int main()
{
    char arg0[] = "/bin/echo";
    char arg1[] = "Hello World";
    char* args[] = { arg0, arg1, nullptr };

    pid_t pid{};
    posix_spawn(&pid, "/bin/echo", nullptr, nullptr, args, environ);
    waitpid(pid, nullptr, 0);
}
