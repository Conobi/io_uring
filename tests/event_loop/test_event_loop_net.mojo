from event_loop import EventLoop, CompletionHandler
from mojix.net.socket import socketpair
from mojix.net.types import AddrFamily, SocketType
from mojix.fd import Fd
from mojix.io_uring import IoUringCqeFlags
from mojix.ctypes import c_void
from memory import UnsafePointer
from testing import assert_equal


comptime TOKEN_SEND: UInt64 = 1
comptime TOKEN_RECV: UInt64 = 2


struct NetCounter(CompletionHandler):
    var send_result: Int32
    var recv_result: Int32

    fn __init__(out self):
        self.send_result = -1
        self.recv_result = -1

    fn __moveinit__(out self, deinit existing: Self):
        self.send_result = existing.send_result
        self.recv_result = existing.recv_result

    fn on_complete(
        mut self, token: UInt64, result: Int32, flags: IoUringCqeFlags
    ):
        if token == TOKEN_SEND:
            self.send_result = result
        elif token == TOKEN_RECV:
            self.recv_result = result


fn test_send_recv_over_socketpair() raises:
    fds = socketpair(AddrFamily.UNIX, SocketType.STREAM)

    # Heap-allocated buffers to avoid SSO stack-pointer issues.
    var send_buf = List[UInt8](capacity=5)
    send_buf.append(ord('h'))
    send_buf.append(ord('e'))
    send_buf.append(ord('l'))
    send_buf.append(ord('l'))
    send_buf.append(ord('o'))
    var recv_buf = List[UInt8](length=5, fill=UInt8(32))

    send_ptr = UnsafePointer[c_void, StaticConstantOrigin](
        unsafe_from_address=Int(send_buf.unsafe_ptr())
    )
    recv_ptr = UnsafePointer[c_void, StaticConstantOrigin](
        unsafe_from_address=Int(recv_buf.unsafe_ptr())
    )

    loop = EventLoop(NetCounter(), sq_entries=8)
    # Pass fds[0]/fds[1] via .fd() (borrows) so the OwnedFds stay alive in `fds`.
    loop.submit_send(fds[0].fd(), send_ptr, 5, TOKEN_SEND)
    loop.submit_recv(fds[1].fd(), recv_ptr, 5, TOKEN_RECV)
    loop.run()

    # Both ops completed — 5 bytes transferred each.
    assert_equal(loop._handler.send_result, Int32(5))
    assert_equal(loop._handler.recv_result, Int32(5))

    # Verify the correct bytes arrived.
    for i in range(5):
        assert_equal(recv_buf[i], send_buf[i])

    # Keep fds alive until after run() so the kernel can use them.
    _ = fds


fn main() raises:
    test_send_recv_over_socketpair()
