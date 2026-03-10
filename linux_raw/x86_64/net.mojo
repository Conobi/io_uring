from ..ctypes import c_ushort, c_uint, c_uchar
from ..utils import DTypeArray

comptime SOCK_STREAM = 1
comptime SOCK_DGRAM = 2
comptime SOCK_RAW = 3
comptime SOCK_RDM = 4
comptime SOCK_SEQPACKET = 5
comptime MSG_DONTWAIT = 64
comptime AF_UNSPEC = 0
comptime AF_UNIX = 1
comptime AF_INET = 2
comptime AF_AX25 = 3
comptime AF_IPX = 4
comptime AF_APPLETALK = 5
comptime AF_NETROM = 6
comptime AF_BRIDGE = 7
comptime AF_ATMPVC = 8
comptime AF_X25 = 9
comptime AF_INET6 = 10
comptime AF_ROSE = 11
comptime AF_DECnet = 12
comptime AF_NETBEUI = 13
comptime AF_SECURITY = 14
comptime AF_KEY = 15
comptime AF_NETLINK = 16
comptime AF_PACKET = 17
comptime AF_ASH = 18
comptime AF_ECONET = 19
comptime AF_ATMSVC = 20
comptime AF_RDS = 21
comptime AF_SNA = 22
comptime AF_IRDA = 23
comptime AF_PPPOX = 24
comptime AF_WANPIPE = 25
comptime AF_LLC = 26
comptime AF_CAN = 29
comptime AF_TIPC = 30
comptime AF_BLUETOOTH = 31
comptime AF_IUCV = 32
comptime AF_RXRPC = 33
comptime AF_ISDN = 34
comptime AF_PHONET = 35
comptime AF_IEEE802154 = 36
comptime AF_CAIF = 37
comptime AF_ALG = 38
comptime AF_NFC = 39
comptime AF_VSOCK = 40
comptime AF_KCM = 41
comptime AF_QIPCRTR = 42
comptime AF_SMC = 43
comptime AF_XDP = 44
comptime AF_MCTP = 45
comptime AF_MAX = 46

comptime MSG_OOB = 1
comptime MSG_PEEK = 2
comptime MSG_DONTROUTE = 4
comptime MSG_CTRUNC = 8
comptime MSG_PROBE = 16
comptime MSG_TRUNC = 32
comptime MSG_EOR = 128
comptime MSG_WAITALL = 256
comptime MSG_FIN = 512
comptime MSG_SYN = 1024
comptime MSG_CONFIRM = 2048
comptime MSG_RST = 4096
comptime MSG_ERRQUEUE = 8192
comptime MSG_NOSIGNAL = 16384
comptime MSG_MORE = 32768
comptime MSG_CMSG_CLOEXEC = 1073741824

comptime IPPROTO_HOPOPTS = 0
comptime IPPROTO_ROUTING = 43
comptime IPPROTO_FRAGMENT = 44
comptime IPPROTO_ICMPV6 = 58
comptime IPPROTO_NONE = 59
comptime IPPROTO_DSTOPTS = 60
comptime IPPROTO_MH = 135

comptime IPPROTO_IP = 0
comptime IPPROTO_ICMP = 1
comptime IPPROTO_IGMP = 2
comptime IPPROTO_IPIP = 4
comptime IPPROTO_TCP = 6
comptime IPPROTO_EGP = 8
comptime IPPROTO_PUP = 12
comptime IPPROTO_UDP = 17
comptime IPPROTO_IDP = 22
comptime IPPROTO_TP = 29
comptime IPPROTO_DCCP = 33
comptime IPPROTO_IPV6 = 41
comptime IPPROTO_RSVP = 46
comptime IPPROTO_GRE = 47
comptime IPPROTO_ESP = 50
comptime IPPROTO_AH = 51
comptime IPPROTO_MTP = 92
comptime IPPROTO_BEETPH = 94
comptime IPPROTO_ENCAP = 98
comptime IPPROTO_PIM = 103
comptime IPPROTO_COMP = 108
comptime IPPROTO_L2TP = 115
comptime IPPROTO_SCTP = 132
comptime IPPROTO_UDPLITE = 136
comptime IPPROTO_MPLS = 137
comptime IPPROTO_ETHERNET = 143
comptime IPPROTO_RAW = 255
comptime IPPROTO_MPTCP = 262
comptime IPPROTO_MAX = 263

comptime __u8 = c_uchar
comptime __u16 = c_ushort
comptime __u32 = c_uint

comptime __be16 = __u16
comptime __be32 = __u32

comptime socklen_t = c_uint

comptime __kernel_sa_family_t = c_ushort


@register_passable("trivial")
struct in_addr:
    var s_addr: __be32

    @always_inline
    fn __init__(out self, s_addr: __be32 = 0):
        self.s_addr = s_addr


@register_passable("trivial")
struct sockaddr_in:
    var sin_family: __kernel_sa_family_t
    var sin_port: __be16
    var sin_addr: in_addr
    var __pad: DTypeArray[DType.uint8, 8]

    @always_inline
    fn __init__(out self):
        self.sin_family = 0
        self.sin_port = 0
        self.sin_addr = in_addr(0)
        self.__pad = DTypeArray[DType.uint8, 8]()


@register_passable("trivial")
struct in6_addr:
    var in6_u: DTypeArray[DType.uint8, 16]


struct sockaddr_in6(ImplicitlyCopyable, Movable):
    var sin6_family: c_ushort
    var sin6_port: __be16
    var sin6_flowinfo: __be32
    var sin6_addr: in6_addr
    var sin6_scope_id: __u32
