// Clang-only: GCC ignores the diagnose_if attribute (see article #86).
__attribute__((diagnose_if(1, "Hello World", "warning")))
void f() {}

int main() { f(); }
