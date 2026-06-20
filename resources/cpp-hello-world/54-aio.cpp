// link with -lrt
#include <aio.h>
#include <unistd.h>

int main()
{
    static char msg[] = "Hello World\n";

    aiocb cb{};
    cb.aio_fildes = STDOUT_FILENO;
    cb.aio_buf = msg;
    cb.aio_nbytes = sizeof(msg) - 1;

    aio_write(&cb);

    const aiocb* list[] = { &cb };
    aio_suspend(list, 1, nullptr);  // block until the write completes
}
