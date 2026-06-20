#include <fcntl.h>
#include <string_view>
#include <unistd.h>

int main()
{
    constexpr std::string_view msg = "Hello World\n";
    int fd = open("/dev/tty", O_WRONLY);
    write(fd, msg.data(), msg.size());
    close(fd);
}
