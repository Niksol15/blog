#include <format>
#include <iostream>
#include <iterator>
#include <string_view>

int main()
{
    constexpr std::string_view message = "Hello World";
    // +1 accounts for the '\n' appended by the format string
    constexpr auto cap = message.size() + 1;
    std::format_to_n(std::ostream_iterator<char>(std::cout), cap, "{}\n", message);
}
