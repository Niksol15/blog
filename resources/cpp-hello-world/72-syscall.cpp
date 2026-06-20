#include <string_view>
#include <sys/syscall.h>
#include <unistd.h>

int main()
{
    constexpr std::string_view msg = "Hello World\n";
    syscall(SYS_write, 1, msg.data(), msg.size());
}
