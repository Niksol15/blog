// link with -luring
#include <liburing.h>
#include <string_view>
#include <unistd.h>

int main()
{
    constexpr std::string_view msg = "Hello World\n";

    io_uring ring{};
    io_uring_queue_init(1, &ring, 0);

    io_uring_sqe* sqe = io_uring_get_sqe(&ring);
    io_uring_prep_write(sqe, STDOUT_FILENO, msg.data(), msg.size(), 0);
    io_uring_submit(&ring);

    io_uring_cqe* cqe = nullptr;
    io_uring_wait_cqe(&ring, &cqe);
    io_uring_cqe_seen(&ring, cqe);
    io_uring_queue_exit(&ring);
}
