#include <iostream>
#include <string_view>

int main()
{
    constexpr std::wstring_view msg = L"Hello World\n";
    std::wcout.rdbuf()->sputn(msg.data(), msg.size());  // wide twin of #13 (sputn)
}
