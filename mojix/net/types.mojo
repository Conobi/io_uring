from mojix.ctypes import c_void
from mojix.utils import _to_be, _size_eq, _align_eq
from linux_raw.x86_64.general import O_CLOEXEC, O_NONBLOCK
from linux_raw.x86_64.net import (
    __kernel_sa_family_t,
    __be32,
    sockaddr_in,
    sockaddr_in6,
    socklen_t,
    in_addr,
    in6_addr,
)
from linux_raw.x86_64.net import *
from linux_raw.utils import DTypeArray
from sys.info import align_of, size_of
from memory import UnsafePointer


comptime SOCK_CLOEXEC = O_CLOEXEC
comptime SOCK_NONBLOCK = O_NONBLOCK

comptime Backlog = c_uint


trait SocketAddr(Defaultable):
    comptime ADDR_LEN: socklen_t

    fn addr_unsafe_ptr(ref self) -> UnsafePointer[c_void, StaticConstantOrigin]:
        ...


trait SocketAddrMut(Defaultable):
    fn addr_unsafe_ptr(ref self) -> UnsafePointer[c_void, StaticConstantOrigin]:
        ...

    fn len_unsafe_ptr(ref self) -> UnsafePointer[c_void, StaticConstantOrigin]:
        ...


trait SocketAddrStor:
    comptime AddrStorType: SocketAddr

    fn addr_stor(ref self, out result: Self.AddrStorType):
        ...


trait SocketAddrStorMut:
    comptime AddrStorMutType: SocketAddrMut

    @staticmethod
    fn addr_stor_mut(out result: Self.AddrStorMutType):
        ...


struct SocketAddrStorV4(TrivialRegisterPassable, SocketAddr):
    comptime ADDR_LEN: socklen_t = size_of[sockaddr_in]()

    var addr: sockaddr_in

    # ===------------------------------------------------------------------=== #
    # Life cycle methods
    # ===------------------------------------------------------------------=== #

    @always_inline
    fn __init__(out self):
        _size_eq[Self, 16]()
        _align_eq[Self, 4]()
        self.addr = sockaddr_in()

    @always_inline
    fn __init__[
        origin: ImmutOrigin
    ](out self, ref [origin]addr: SocketAddrV4):
        _size_eq[Self, 16]()
        _align_eq[Self, 4]()
        _size_eq[addr.Octets, __be32]()
        _align_eq[addr.Octets, __be32]()

        self.addr = sockaddr_in()
        self.addr.sin_family = AddrFamily.INET.id
        self.addr.sin_port = _to_be(addr.port)
        self.addr.sin_addr = in_addr(
            UnsafePointer(to=addr.octets())
            .bitcast[__be32]()
            .load[alignment = align_of[addr.Octets]()]()
        )
        self.addr.__pad = DTypeArray[DType.uint8, 8]()

    # ===------------------------------------------------------------------=== #
    # Trait implementations
    # ===------------------------------------------------------------------=== #

    @always_inline
    fn addr_unsafe_ptr(ref self) -> UnsafePointer[c_void, StaticConstantOrigin]:
        return UnsafePointer[c_void, StaticConstantOrigin](
            unsafe_from_address=Int(UnsafePointer(to=self.addr))
        )


comptime SocketAddrStorMutV4 = SocketAddrStorAnyMut[SocketAddrStorV4]


struct SocketAddrStorAnyMut[Addr: SocketAddr](SocketAddrMut):
    var addr: Self.Addr
    var len: socklen_t

    # ===------------------------------------------------------------------=== #
    # Life cycle methods
    # ===------------------------------------------------------------------=== #

    @always_inline
    fn __init__(out self):
        self.addr = Self.Addr()
        self.len = Self.Addr.ADDR_LEN

    # ===------------------------------------------------------------------=== #
    # Trait implementations
    # ===------------------------------------------------------------------=== #

    @always_inline
    fn addr_unsafe_ptr(ref self) -> UnsafePointer[c_void, StaticConstantOrigin]:
        return self.addr.addr_unsafe_ptr()

    @always_inline
    fn len_unsafe_ptr(ref self) -> UnsafePointer[c_void, StaticConstantOrigin]:
        return UnsafePointer[c_void, StaticConstantOrigin](
            unsafe_from_address=Int(UnsafePointer(to=self.len))
        )


struct IpAddrV4(TrivialRegisterPassable):
    comptime Octets = SIMD[DType.uint8, 4]

    var octets: Self.Octets

    # ===------------------------------------------------------------------=== #
    # Life cycle methods
    # ===------------------------------------------------------------------=== #

    @always_inline
    fn __init__(out self, a: UInt8, b: UInt8, c: UInt8, d: UInt8):
        self.octets = Self.Octets(a, b, c, d)


struct SocketAddrV4(TrivialRegisterPassable, SocketAddrStor, SocketAddrStorMut):
    comptime AddrStorType: SocketAddr = SocketAddrStorV4
    comptime AddrStorMutType: SocketAddrMut = SocketAddrStorMutV4
    comptime Octets = IpAddrV4.Octets

    var ip: IpAddrV4
    var port: UInt16

    # ===------------------------------------------------------------------=== #
    # Life cycle methods
    # ===------------------------------------------------------------------=== #

    @always_inline
    fn __init__(
        out self, a: UInt8, b: UInt8, c: UInt8, d: UInt8, *, port: UInt16
    ):
        self.ip = IpAddrV4(a, b, c, d)
        self.port = port

    # ===-------------------------------------------------------------------===#
    # Methods
    # ===-------------------------------------------------------------------===#

    @always_inline
    fn octets(ref self) -> ref [self.ip.octets] Self.Octets:
        return self.ip.octets

    # ===------------------------------------------------------------------=== #
    # Trait implementations
    # ===------------------------------------------------------------------=== #

    @always_inline
    fn addr_stor(ref self, out result: Self.AddrStorType):
        result = Self.AddrStorType(self)

    @staticmethod
    @always_inline
    fn addr_stor_mut(out result: Self.AddrStorMutType):
        result = Self.AddrStorMutType()


struct IpAddrV6(TrivialRegisterPassable):
    comptime Segments = SIMD[DType.uint16, 8]

    var segments: Self.Segments

    # ===------------------------------------------------------------------=== #
    # Life cycle methods
    # ===------------------------------------------------------------------=== #

    @always_inline
    fn __init__(
        out self,
        a: UInt16,
        b: UInt16,
        c: UInt16,
        d: UInt16,
        e: UInt16,
        f: UInt16,
        g: UInt16,
        h: UInt16,
    ):
        self.segments = Self.Segments(a, b, c, d, e, f, g, h)


struct SocketAddrStorV6(TrivialRegisterPassable, SocketAddr):
    comptime ADDR_LEN: socklen_t = size_of[sockaddr_in6]()

    var addr: sockaddr_in6

    # ===------------------------------------------------------------------=== #
    # Life cycle methods
    # ===------------------------------------------------------------------=== #

    @always_inline
    fn __init__(out self):
        _size_eq[Self, 28]()
        _align_eq[Self, 4]()
        self.addr = sockaddr_in6()

    @always_inline
    fn __init__[
        origin: ImmutOrigin
    ](out self, ref [origin]addr: SocketAddrV6):
        _size_eq[Self, 28]()
        _align_eq[Self, 4]()

        self.addr = sockaddr_in6()
        self.addr.sin6_family = AddrFamily.INET6.id
        self.addr.sin6_port = _to_be(addr.port)
        self.addr.sin6_flowinfo = 0
        # Convert 8×uint16 segments (host order) to 16 big-endian bytes.
        # _to_be byte-swaps each uint16 to network (big-endian) order.
        # We then copy the resulting 16 bytes into sin6_addr.in6_u via
        # UnsafePointer: cast the DTypeArray storage to uint8 on both sides
        # and copy 16 bytes.
        var be_segs = _to_be(addr.segments())
        var src = UnsafePointer(to=be_segs).bitcast[UInt8]()
        var dst = UnsafePointer(to=self.addr.sin6_addr.in6_u.array).bitcast[UInt8]()
        for i in range(16):
            dst[i] = src[i]
        self.addr.sin6_scope_id = addr.scope_id

    # ===------------------------------------------------------------------=== #
    # Trait implementations
    # ===------------------------------------------------------------------=== #

    @always_inline
    fn addr_unsafe_ptr(ref self) -> UnsafePointer[c_void, StaticConstantOrigin]:
        return UnsafePointer[c_void, StaticConstantOrigin](
            unsafe_from_address=Int(UnsafePointer(to=self.addr))
        )


comptime SocketAddrStorMutV6 = SocketAddrStorAnyMut[SocketAddrStorV6]


struct SocketAddrV6(TrivialRegisterPassable, SocketAddrStor, SocketAddrStorMut):
    comptime AddrStorType: SocketAddr = SocketAddrStorV6
    comptime AddrStorMutType: SocketAddrMut = SocketAddrStorMutV6
    comptime Segments = IpAddrV6.Segments

    var ip: IpAddrV6
    var port: UInt16
    var scope_id: UInt32

    # ===------------------------------------------------------------------=== #
    # Life cycle methods
    # ===------------------------------------------------------------------=== #

    @always_inline
    fn __init__(
        out self,
        a: UInt16,
        b: UInt16,
        c: UInt16,
        d: UInt16,
        e: UInt16,
        f: UInt16,
        g: UInt16,
        h: UInt16,
        *,
        port: UInt16,
        scope_id: UInt32 = 0,
    ):
        self.ip = IpAddrV6(a, b, c, d, e, f, g, h)
        self.port = port
        self.scope_id = scope_id

    # ===-------------------------------------------------------------------===#
    # Methods
    # ===-------------------------------------------------------------------===#

    @always_inline
    fn segments(ref self) -> ref [self.ip.segments] Self.Segments:
        return self.ip.segments

    # ===------------------------------------------------------------------=== #
    # Trait implementations
    # ===------------------------------------------------------------------=== #

    @always_inline
    fn addr_stor(ref self, out result: Self.AddrStorType):
        result = Self.AddrStorType(self)

    @staticmethod
    @always_inline
    fn addr_stor_mut(out result: Self.AddrStorMutType):
        result = Self.AddrStorMutType()


comptime RawSocketType = c_uint


struct SocketType(TrivialRegisterPassable):
    """`SOCK_*` constants for use with `socket`."""

    comptime STREAM = Self(unsafe_id=SOCK_STREAM)
    comptime DGRAM = Self(unsafe_id=SOCK_DGRAM)
    comptime SEQPACKET = Self(unsafe_id=SOCK_SEQPACKET)
    comptime RAW = Self(unsafe_id=SOCK_RAW)
    comptime RDM = Self(unsafe_id=SOCK_RDM)

    var id: RawSocketType

    @always_inline("nodebug")
    fn __init__(out self, *, unsafe_id: RawSocketType):
        self.id = unsafe_id


struct SocketFlags(TrivialRegisterPassable, Defaultable):
    """`SOCK_*` constants for use with `socket`."""

    comptime NONBLOCK = Self(SOCK_NONBLOCK)
    comptime CLOEXEC = Self(SOCK_CLOEXEC)

    var value: c_uint

    @always_inline("nodebug")
    fn __init__(out self):
        self.value = 0

    @always_inline("nodebug")
    @implicit
    fn __init__(out self, value: c_uint):
        self.value = value

    @always_inline("nodebug")
    fn __or__(self, rhs: Self) -> Self:
        """Returns `self | rhs`.

        Args:
            rhs: The RHS value.

        Returns:
            `self | rhs`.
        """
        return self.value | rhs.value


comptime RawAddrFamily = __kernel_sa_family_t


struct AddrFamily(TrivialRegisterPassable):
    """`AF_*` constants for use with `socket`."""

    comptime UNSPEC = Self(unsafe_id=AF_UNSPEC)
    comptime UNIX = Self(unsafe_id=AF_UNIX)
    comptime INET = Self(unsafe_id=AF_INET)
    comptime INET6 = Self(unsafe_id=AF_INET6)
    comptime NETLINK = Self(unsafe_id=AF_NETLINK)

    var id: RawAddrFamily

    @always_inline("nodebug")
    fn __init__(out self, *, unsafe_id: RawAddrFamily):
        self.id = unsafe_id


struct Protocol(TrivialRegisterPassable, Defaultable):
    """`IPPROTO_*` and other constants for use with `socket`."""

    comptime IP = Self(unsafe_id=IPPROTO_IP)
    comptime ICMP = Self(unsafe_id=IPPROTO_ICMP)
    comptime IGMP = Self(unsafe_id=IPPROTO_IGMP)
    comptime IPIP = Self(unsafe_id=IPPROTO_IPIP)
    comptime TCP = Self(unsafe_id=IPPROTO_TCP)
    comptime EGP = Self(unsafe_id=IPPROTO_EGP)
    comptime PUP = Self(unsafe_id=IPPROTO_PUP)
    comptime UDP = Self(unsafe_id=IPPROTO_UDP)
    comptime IDP = Self(unsafe_id=IPPROTO_IDP)
    comptime TP = Self(unsafe_id=IPPROTO_TP)
    comptime DCCP = Self(unsafe_id=IPPROTO_DCCP)
    comptime IPV6 = Self(unsafe_id=IPPROTO_IPV6)
    comptime RSVP = Self(unsafe_id=IPPROTO_RSVP)
    comptime GRE = Self(unsafe_id=IPPROTO_GRE)
    comptime ESP = Self(unsafe_id=IPPROTO_ESP)
    comptime AH = Self(unsafe_id=IPPROTO_AH)
    comptime MTP = Self(unsafe_id=IPPROTO_MTP)
    comptime BEETPH = Self(unsafe_id=IPPROTO_BEETPH)
    comptime ENCAP = Self(unsafe_id=IPPROTO_ENCAP)
    comptime PIM = Self(unsafe_id=IPPROTO_PIM)
    comptime COMP = Self(unsafe_id=IPPROTO_COMP)
    comptime SCTP = Self(unsafe_id=IPPROTO_SCTP)
    comptime UDPLITE = Self(unsafe_id=IPPROTO_UDPLITE)
    comptime MPLS = Self(unsafe_id=IPPROTO_MPLS)
    comptime ETHERNET = Self(unsafe_id=IPPROTO_ETHERNET)
    comptime RAW = Self(unsafe_id=IPPROTO_RAW)
    comptime MPTCP = Self(unsafe_id=IPPROTO_MPTCP)
    comptime FRAGMENT = Self(unsafe_id=IPPROTO_FRAGMENT)
    comptime ICMPV6 = Self(unsafe_id=IPPROTO_ICMPV6)
    comptime MH = Self(unsafe_id=IPPROTO_MH)
    comptime ROUTING = Self(unsafe_id=IPPROTO_ROUTING)

    var id: c_uint

    @always_inline("nodebug")
    fn __init__(out self):
        constrained[IPPROTO_IP == 0]()
        self = Self(unsafe_id=IPPROTO_IP)

    @always_inline("nodebug")
    fn __init__(out self, *, unsafe_id: c_uint):
        self.id = unsafe_id


struct SendFlags(TrivialRegisterPassable, Defaultable):
    """`MSG_*` flags for use with `send`, `send_to`, and related functions."""

    comptime CONFIRM = Self(MSG_CONFIRM)
    comptime DONTROUTE = Self(MSG_DONTROUTE)
    comptime DONTWAIT = Self(MSG_DONTWAIT)
    comptime EOR = Self(MSG_EOR)
    comptime MORE = Self(MSG_MORE)
    comptime NOSIGNAL = Self(MSG_NOSIGNAL)
    comptime OOB = Self(MSG_OOB)

    var value: c_uint

    @always_inline("nodebug")
    fn __init__(out self):
        self.value = 0

    @always_inline("nodebug")
    @implicit
    fn __init__(out self, value: c_uint):
        self.value = value


struct RecvFlags(TrivialRegisterPassable, Defaultable):
    """`MSG_*` flags for use with `recv`, `recvfrom`, and related functions."""

    comptime CMSG_CLOEXEC = Self(MSG_CMSG_CLOEXEC)
    comptime DONTWAIT = Self(MSG_DONTWAIT)
    comptime ERRQUEUE = Self(MSG_ERRQUEUE)
    comptime OOB = Self(MSG_OOB)
    comptime PEEK = Self(MSG_PEEK)
    comptime TRUNC = Self(MSG_TRUNC)
    comptime WAITALL = Self(MSG_WAITALL)

    var value: c_uint

    @always_inline("nodebug")
    fn __init__(out self):
        self.value = 0

    @always_inline("nodebug")
    @implicit
    fn __init__(out self, value: c_uint):
        self.value = value
