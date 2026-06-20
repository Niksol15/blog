#include <cstdio>
#include <string_view>

int main()
{
    constexpr std::string_view msg = "Hello World\n";
    fwrite(msg.data(), 1, msg.size(), stdout);
}
