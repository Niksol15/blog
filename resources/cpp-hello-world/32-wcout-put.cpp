#include <iostream>
#include <string_view>

int main()
{
    for (wchar_t c : std::wstring_view(L"Hello World\n"))
    {
        std::wcout.put(c);  // wide twin of #14 (cout.put)
    }
}
