// GCC / Clang
__attribute__((error("Hello World")))
void f();

int main() { f(); }
