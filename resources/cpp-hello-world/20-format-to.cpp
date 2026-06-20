#include <format>
#include <iostream>
#include <iterator>
#include <string_view>

int main()
{
    constexpr std::string_view message = "Hello World";
    std::format_to(std::ostream_iterator<char>(std::cout), "{}\n", message);
}
