#include <fcntl.h>
#include <string_view>
#include <unistd.h>

int main()
{
    constexpr std::string_view msg = "Hello World\n";
    constexpr auto len = msg.size();

    int pfd[2]{};
    pipe(pfd);
    write(pfd[1], msg.data(), len);
    splice(pfd[0], nullptr, STDOUT_FILENO, nullptr, len, 0);
    close(pfd[0]);
    close(pfd[1]);
}
