#include <string_view>
#include <unistd.h>

int main()
{
    constexpr std::string_view msg = "Hello World\n";
    write(STDOUT_FILENO, msg.data(), msg.size());
}
