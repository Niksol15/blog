int main()
{
    const char msg[] = "Hello World\n";
    asm volatile(
        "mov $1, %%rax\n"   // syscall number: write
        "mov $1, %%rdi\n"   // fd: stdout
        "mov %0, %%rsi\n"   // buf: msg
        "mov %1, %%rdx\n"   // count: msg length, without the '\0'
        "syscall"
        :
        : "r"(msg), "i"(sizeof(msg) - 1)
        : "rax", "rdi", "rsi", "rdx", "rcx", "r11", "memory");
}
