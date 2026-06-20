template <int N>
struct HelloWorld
{
    static_assert(N != N, "Hello World");
};

template struct HelloWorld<42>;
