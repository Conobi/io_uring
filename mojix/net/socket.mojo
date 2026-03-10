from .syscalls import _socket, _bind, _listen, _socketpair
from .types import (
    Backlog,
    AddrFamily,
    SocketType,
    SocketFlags,
    Protocol,
    SocketAddr,
    SocketAddrStor,
    SocketAddrV4,
)
from mojix.fd import OwnedFd, FileDescriptor


@always_inline
fn socket(
    domain: AddrFamily,
    type: SocketType,
) raises -> OwnedFd[False]:
    """Creates a socket.
    [Linux]: https://man7.org/linux/man-pages/man2/socket.2.html.
    """
    return _socket(domain, type, SocketFlags(), Protocol())


@always_inline
fn socket(
    domain: AddrFamily,
    type: SocketType,
    protocol: Protocol,
) raises -> OwnedFd[False]:
    """Creates a socket.
    [Linux]: https://man7.org/linux/man-pages/man2/socket.2.html.
    """
    return _socket(domain, type, SocketFlags(), protocol)


@always_inline
fn socket(
    domain: AddrFamily,
    type: SocketType,
    flags: SocketFlags,
    protocol: Protocol,
) raises -> OwnedFd[False]:
    """Creates a socket.
    [Linux]: https://man7.org/linux/man-pages/man2/socket.2.html.
    """
    return _socket(domain, type, flags, protocol)


@always_inline
fn bind[
    Fd: FileDescriptor, Addr: SocketAddrStor
](fd: Fd, ref addr: Addr) raises:
    """Binds a socket to an address.
    [Linux]: https://man7.org/linux/man-pages/man2/bind.2.html.
    """
    stor = addr.addr_stor()
    _bind(fd, stor)


@always_inline
fn bind[Fd: FileDescriptor, Addr: SocketAddr](fd: Fd, ref addr: Addr) raises:
    """Binds a socket to an address.
    [Linux]: https://man7.org/linux/man-pages/man2/bind.2.html.
    """
    _bind(fd, addr)


@always_inline
fn listen[Fd: FileDescriptor](fd: Fd, backlog: Backlog) raises:
    """Enables listening for incoming connections.
    [Linux]: https://man7.org/linux/man-pages/man2/listen.2.html.
    """
    _listen(fd, backlog)


@always_inline
fn socketpair(
    domain: AddrFamily,
    type: SocketType,
) raises -> Tuple[OwnedFd[False], OwnedFd[False]]:
    """Creates a pair of connected sockets.
    [Linux]: https://man7.org/linux/man-pages/man2/socketpair.2.html.
    """
    return _socketpair(domain, type, SocketFlags(), Protocol())
