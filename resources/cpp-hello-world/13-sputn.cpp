#include <iostream>
#include <string_view>

int main()
{
    constexpr std::string_view msg = "Hello World\n";
    std::cout.rdbuf()->sputn(msg.data(), msg.size());
}
