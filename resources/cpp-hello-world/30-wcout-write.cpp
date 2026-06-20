#include <iostream>
#include <string_view>

int main()
{
    constexpr std::wstring_view msg = L"Hello World\n";
    std::wcout.write(msg.data(), msg.size());  // wide twin of #12 (cout.write)
}
