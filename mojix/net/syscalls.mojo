from .types import (
    Backlog,
    AddrFamily,
    SocketType,
    SocketFlags,
    Protocol,
    SocketAddr,
)
from mojix.ctypes import c_int
from mojix.utils import _size_eq
from mojix.fd import UnsafeFd, OwnedFd, FileDescriptor
from mojix.errno import unsafe_decode_result, unsafe_decode_none
from linux_raw.utils import is_x86_64, DTypeArray
from linux_raw.x86_64.general import __NR_socket, __NR_bind, __NR_listen, __NR_socketpair
from linux_raw.x86_64.syscall import syscall


@always_inline
fn _socket(
    domain: AddrFamily,
    type: SocketType,
    flags: SocketFlags,
    protocol: Protocol,
) raises -> OwnedFd[False]:
    constrained[is_x86_64()]()
    _size_eq[SocketType, c_int]()
    _size_eq[SocketFlags, c_int]()
    _size_eq[Protocol, c_int]()

    res = syscall[__NR_socket, Scalar[DType.int64], uses_memory=False](
        UInt32(domain.id), type.id | flags.value, protocol
    )
    return OwnedFd[False](unsafe_fd=unsafe_decode_result[DType.int32](res))


@always_inline
fn _bind[Fd: FileDescriptor, Addr: SocketAddr](fd: Fd, ref addr: Addr) raises:
    constrained[is_x86_64()]()

    res = syscall[__NR_bind, Scalar[DType.int64], uses_memory=False](
        fd.fd(), addr.addr_unsafe_ptr(), Addr.ADDR_LEN
    )
    unsafe_decode_none(res)


@always_inline
fn _listen[Fd: FileDescriptor](fd: Fd, backlog: Backlog) raises:
    constrained[is_x86_64()]()
    _size_eq[Backlog, c_int]()

    res = syscall[__NR_listen, Scalar[DType.int64], uses_memory=False](
        fd.fd(), backlog
    )
    unsafe_decode_none(res)


@always_inline
fn _socketpair(
    domain: AddrFamily,
    type: SocketType,
    flags: SocketFlags,
    protocol: Protocol,
) raises -> Tuple[OwnedFd[False], OwnedFd[False]]:
    constrained[is_x86_64()]()
    _size_eq[SocketType, c_int]()
    _size_eq[SocketFlags, c_int]()
    _size_eq[Protocol, c_int]()

    sv = DTypeArray[DType.int32, 2]()
    # `uses_memory=False` is intentionally omitted: the kernel writes the two
    # file descriptors into `sv`, so memory effects must not be suppressed.
    res = syscall[__NR_socketpair, Scalar[DType.int64]](
        UInt32(domain.id), type.id | flags.value, protocol,
        UnsafePointer(to=sv.array).bitcast[Scalar[DType.int32]](),
    )
    unsafe_decode_none(res)
    return (OwnedFd[False](unsafe_fd=sv[UInt(0)]), OwnedFd[False](unsafe_fd=sv[UInt(1)]))
