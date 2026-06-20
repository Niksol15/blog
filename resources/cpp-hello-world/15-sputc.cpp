#include <iostream>
#include <string_view>

int main()
{
    for (char c : std::string_view("Hello World\n"))
    {
        std::cout.rdbuf()->sputc(c);
    }
}
