from mojix.net.socket import socket, bind, setsockopt
from mojix.net.types import AddrFamily, SocketType, Protocol, SocketAddrV4, SocketAddrStorV4
from io_uring import IoUring
from io_uring.op import SendMsg, RecvMsg
from linux_raw.x86_64.net import msghdr, iovec, SOL_SOCKET, SO_REUSEADDR
from mojix.ctypes import c_int, c_uint, c_void
from std.memory import UnsafePointer
from std.memory.unsafe_pointer import alloc as heap_alloc


fn main() raises:
    ring = IoUring[](sq_entries=8)
    sender_fd = socket(AddrFamily.INET, SocketType.DGRAM, Protocol.UDP)
    receiver_fd = socket(AddrFamily.INET, SocketType.DGRAM, Protocol.UDP)

    # SO_REUSEADDR to avoid EADDRINUSE on repeated runs.
    var optval: c_int = 1
    setsockopt(
        receiver_fd.fd(),
        c_int(SOL_SOCKET),
        c_int(SO_REUSEADDR),
        UnsafePointer[c_void, StaticConstantOrigin](
            unsafe_from_address=Int(UnsafePointer(to=optval))
        ),
        c_uint(4),
    )

    var sa = SocketAddrV4(127, 0, 0, 1, port=0)
    bind(sender_fd, sa)
    var ra = SocketAddrV4(127, 0, 0, 1, port=19995)
    bind(receiver_fd, ra)

    # Heap-allocate iov and msg to guarantee stable addresses.
    # TrivialRegisterPassable structs on the stack may live in registers;
    # UnsafePointer(to=stack_var) can return garbage. Heap alloc is safe.
    # Fields are written via bitcast to UInt64/UInt32 pointers because
    # ptr[0].field = value modifies a COPY for TrivialRegisterPassable.
    var snd_iov = heap_alloc[iovec](1)
    var snd_msg = heap_alloc[msghdr](1)
    var rcv_iov = heap_alloc[iovec](1)
    var rcv_msg = heap_alloc[msghdr](1)

    var dest = SocketAddrStorV4(ra)
    var payload = String("test")
    var pbytes = payload.as_bytes()

    # Write send iovec fields via bitcast.
    var snd_iov_u64 = snd_iov.bitcast[UInt64]()
    snd_iov_u64[0] = UInt64(Int(pbytes.unsafe_ptr()))  # iov_base
    snd_iov_u64[1] = UInt64(len(payload))               # iov_len

    # Write send msghdr fields via bitcast.
    # msghdr layout: [msg_name:u64, msg_namelen:u32, _pad:u32,
    #                 msg_iov:u64, msg_iovlen:u64,
    #                 msg_control:u64, msg_controllen:u64,
    #                 msg_flags:i32, _pad:u32]
    var sm_u64 = snd_msg.bitcast[UInt64]()
    var sm_u32 = snd_msg.bitcast[UInt32]()
    for i in range(7):
        sm_u64[i] = 0
    sm_u64[0] = UInt64(Int(dest.addr_unsafe_ptr()))  # msg_name
    sm_u32[2] = UInt32(SocketAddrStorV4.ADDR_LEN)    # msg_namelen at byte 8
    sm_u64[2] = UInt64(Int(snd_iov))                  # msg_iov at byte 16
    sm_u64[3] = 1                                      # msg_iovlen at byte 24

    # Write recv iovec + msghdr.
    var rcv_buf = heap_alloc[UInt8](64)
    var rcv_iov_u64 = rcv_iov.bitcast[UInt64]()
    rcv_iov_u64[0] = UInt64(Int(rcv_buf))  # iov_base
    rcv_iov_u64[1] = 64                     # iov_len

    var rm_u64 = rcv_msg.bitcast[UInt64]()
    for i in range(7):
        rm_u64[i] = 0
    rm_u64[2] = UInt64(Int(rcv_iov))  # msg_iov
    rm_u64[3] = 1                      # msg_iovlen

    # Submit send.
    sq = ring.sq()
    if not sq:
        raise "SQ full"
    _ = SendMsg(
        sq.__next__(),
        sender_fd.fd(),
        UnsafePointer[c_void, StaticConstantOrigin](
            unsafe_from_address=Int(snd_msg)
        ),
    ).user_data(1)

    # Submit recv.
    sq2 = ring.sq()
    if not sq2:
        raise "SQ full"
    _ = RecvMsg(
        sq2.__next__(),
        receiver_fd.fd(),
        UnsafePointer[c_void, StaticConstantOrigin](
            unsafe_from_address=Int(rcv_msg)
        ),
    ).user_data(2)

    # Submit both and wait for 2 completions.
    _ = ring.submit_and_wait(wait_nr=2)

    var send_res: Int32 = -1
    var recv_res: Int32 = -1
    for cqe in ring.cq(wait_nr=0):
        if cqe.user_data == 1:
            send_res = cqe.res
        elif cqe.user_data == 2:
            recv_res = cqe.res
    _ = ring

    debug_assert(send_res > 0, "send failed: " + String(send_res))
    debug_assert(recv_res == 4, "recv wrong bytes: " + String(recv_res))

    # Verify data matches.
    for i in range(4):
        debug_assert(rcv_buf[i] == pbytes[i], "data mismatch at " + String(i))

    snd_iov.free()
    snd_msg.free()
    rcv_iov.free()
    rcv_msg.free()
    rcv_buf.free()
    _ = sender_fd
    _ = receiver_fd
    print("All UDP tests passed")
