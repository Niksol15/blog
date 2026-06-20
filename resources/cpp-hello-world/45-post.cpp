// build with -fcontracts
int f(int x) post(false && "Hello World") { return x; }

int main() { return f(0); }
