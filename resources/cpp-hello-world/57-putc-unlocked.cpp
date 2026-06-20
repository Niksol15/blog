#include <cstdio>
#include <string_view>

int main()
{
    for (char c : std::string_view("Hello World\n"))
    {
        putc_unlocked(c, stdout);
    }
}
