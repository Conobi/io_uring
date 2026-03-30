from io_uring.qp import IoUring
from io_uring.op import Nop, Read, Write, Recv, Send, Accept
from mojix.io_uring import IoUringCqeFlags
from mojix.fd import Fd
from mojix.ctypes import c_void
from memory import UnsafePointer


trait CompletionHandler(Movable, ImplicitlyDestructible):
    fn on_complete(mut self, token: UInt64, result: Int32, flags: IoUringCqeFlags):
        ...


struct EventLoop[Handler: CompletionHandler]:
    var _ring: IoUring[]
    var _pending: UInt32
    var _handler: Self.Handler

    fn __init__(out self, var handler: Self.Handler, sq_entries: UInt32 = 64) raises:
        self._ring = IoUring[](sq_entries=sq_entries)
        self._pending = 0
        self._handler = handler^

    fn submit_nop(mut self, token: UInt64 = 0) raises:
        sq = self._ring.sq()
        if not sq:
            raise "SQ full"
        _ = Nop(sq.__next__()).user_data(token)
        self._pending += 1

    fn submit_read(
        mut self,
        fd: Fd,
        buf: UnsafePointer[c_void, StaticConstantOrigin],
        len: UInt,
        token: UInt64,
        offset: UInt64 = 0,
    ) raises:
        sq = self._ring.sq()
        if not sq:
            raise "SQ full"
        _ = Read(sq.__next__(), fd, buf, len).user_data(token).offset(offset)
        self._pending += 1

    fn submit_write(
        mut self,
        fd: Fd,
        buf: UnsafePointer[c_void, StaticConstantOrigin],
        len: UInt,
        token: UInt64,
        offset: UInt64 = 0,
    ) raises:
        sq = self._ring.sq()
        if not sq:
            raise "SQ full"
        _ = Write(sq.__next__(), fd, buf, len).user_data(token).offset(offset)
        self._pending += 1

    fn submit_recv(
        mut self,
        fd: Fd,
        buf: UnsafePointer[c_void, StaticConstantOrigin],
        len: UInt,
        token: UInt64,
    ) raises:
        sq = self._ring.sq()
        if not sq:
            raise "SQ full"
        _ = Recv(sq.__next__(), fd, buf, len).user_data(token)
        self._pending += 1

    fn submit_send(
        mut self,
        fd: Fd,
        buf: UnsafePointer[c_void, StaticConstantOrigin],
        len: UInt,
        token: UInt64,
    ) raises:
        sq = self._ring.sq()
        if not sq:
            raise "SQ full"
        _ = Send(sq.__next__(), fd, buf, len).user_data(token)
        self._pending += 1

    fn submit_accept(mut self, fd: Fd, token: UInt64) raises:
        sq = self._ring.sq()
        if not sq:
            raise "SQ full"
        _ = Accept(sq.__next__(), fd).user_data(token)
        self._pending += 1

    fn poll(mut self, *, wait_nr: UInt32 = 1) raises:
        _ = self._ring.submit_and_wait(wait_nr=wait_nr)
        for cqe in self._ring.cq(wait_nr=0):
            self._handler.on_complete(cqe.user_data, cqe.res, cqe.flags)
            self._pending -= 1

    fn run(mut self) raises:
        while self._pending > 0:
            self.poll(wait_nr=1)
