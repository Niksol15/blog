// C++26 constexpr exceptions: throwing during constant evaluation. When the
// exception escapes the constant expression, GCC 16 prints what() right in the
// diagnostic. Compile-time twin of the uncaught throw (#41), with zero runtime.
// Needs GCC: Clang 22 hasn't implemented P3068 yet (it rejects the throw without
// printing what()).
#include <stdexcept>

constexpr int hello() { throw std::runtime_error("Hello World"); }

constexpr int x = hello();   // forces constant evaluation -> the throw escapes

int main() {}
