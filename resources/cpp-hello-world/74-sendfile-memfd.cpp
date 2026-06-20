#include <string_view>
#include <sys/mman.h>
#include <sys/sendfile.h>
#include <unistd.h>

int main()
{
    constexpr std::string_view msg = "Hello World\n";
    constexpr auto len = msg.size();

    // "hello" is just a debug label for the anonymous in-memory file
    // (visible in /proc/self/fd); the name is never part of the output.
    int fd = memfd_create("hello", 0);
    write(fd, msg.data(), len);
    lseek(fd, 0, SEEK_SET);
    sendfile(STDOUT_FILENO, fd, nullptr, len);
    close(fd);
}
