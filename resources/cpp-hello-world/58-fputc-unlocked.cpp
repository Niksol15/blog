#include <cstdio>
#include <string_view>

int main()
{
    for (char c : std::string_view("Hello World\n"))
    {
        fputc_unlocked(c, stdout);
    }
}
