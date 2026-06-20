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
    cb.aio_lio_opcode = LIO_WRITE;

    aiocb* list[] = { &cb };
    lio_listio(LIO_WAIT, list, 1, nullptr);  // submit the whole list, block till done
}
