from mojix.net.socket import socketpair
from mojix.net.types import AddrFamily, SocketType
from testing import assert_true


fn test_socketpair_creates_connected_fds() raises:
    fds = socketpair(AddrFamily.UNIX, SocketType.STREAM)
    # Both fds must be non-negative valid file descriptors.
    assert_true(fds[0].unsafe_fd() >= 0)
    assert_true(fds[1].unsafe_fd() >= 0)
    # The two fds must be distinct.
    assert_true(fds[0].unsafe_fd() != fds[1].unsafe_fd())


fn main() raises:
    test_socketpair_creates_connected_fds()
