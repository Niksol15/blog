#include <cwchar>
#include <string_view>

int main()
{
    for (wchar_t c : std::wstring_view(L"Hello World\n"))
    {
        putwchar_unlocked(c);
    }
}
