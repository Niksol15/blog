#include <algorithm>
#include <iostream>
#include <iterator>
#include <string_view>

int main()
{
    constexpr std::string_view msg = "Hello World\n";
    std::ranges::copy(msg, std::ostream_iterator<char>(std::cout));
}
