// build with -fcontracts
int f(int x) pre(false && "Hello World") { return x; }

int main() { return f(0); }
