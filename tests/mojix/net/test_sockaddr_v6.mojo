from mojix.net.types import (
    IpAddrV6,
    SocketAddrV6,
    SocketAddrStorV6,
    SocketAddrStorMutV6,
)
from linux_raw.x86_64.net import sockaddr_in6, AF_INET6
from std.sys.info import size_of
from std.testing import assert_equal, assert_true


fn test_ipv6_loopback_addr_stor() raises:
    """Creates IPv6 loopback (::1) on port 8443 and converts to SocketAddrStorV6."""
    var addr = SocketAddrV6(0, 0, 0, 0, 0, 0, 0, 1, port=8443)

    # Verify the high-level fields.
    assert_equal(addr.port, 8443, "port must round-trip")
    assert_equal(Int(addr.scope_id), 0, "default scope_id must be 0")

    # Convert to the kernel-level storage struct.
    var stor = SocketAddrStorV6(addr)

    # sin6_family must be AF_INET6 (10 on Linux).
    assert_equal(Int(stor.addr.sin6_family), AF_INET6, "sin6_family must be AF_INET6")

    # Port is stored in big-endian.  8443 = 0x20FB; in big-endian that is the
    # two-byte sequence [0x20, 0xFB], so the uint16 big-endian value is 0x20FB
    # when read on a little-endian host it appears byte-swapped as 0xFB20.
    # We verify that the stored value differs from the host-endian value on a
    # little-endian platform (i.e. the swap happened) by checking it equals
    # the expected network-order representation.
    # Network byte order (big-endian) of 8443 = (8443 >> 8) | ((8443 & 0xFF) << 8)
    var expected_be_port = UInt16((8443 >> 8) | ((8443 & 0xFF) << 8))
    assert_equal(stor.addr.sin6_port, expected_be_port, "sin6_port must be big-endian")

    # For ::1 the last byte of the 16-byte address is 1, all others are 0.
    # Byte 15 (index 15) must be 1.
    assert_equal(
        Int(stor.addr.sin6_addr.in6_u[UInt(15)]),
        1,
        "last byte of ::1 must be 1",
    )
    # Byte 0 must be 0.
    assert_equal(
        Int(stor.addr.sin6_addr.in6_u[UInt(0)]),
        0,
        "first byte of ::1 must be 0",
    )

    # addr_unsafe_ptr must be non-null.
    var ptr = stor.addr_unsafe_ptr()
    assert_true(Int(ptr) != 0, "addr_unsafe_ptr must be non-null")


fn test_ipv6_addr_stor_mut_default() raises:
    """SocketAddrStorMutV6 default initialises with ADDR_LEN = size_of[sockaddr_in6]."""
    var mut_stor = SocketAddrStorMutV6()
    assert_equal(
        Int(mut_stor.len),
        size_of[sockaddr_in6](),
        "len must equal size_of[sockaddr_in6]",
    )
    # addr_unsafe_ptr must be non-null.
    assert_true(Int(mut_stor.addr_unsafe_ptr()) != 0, "addr_unsafe_ptr non-null")
    # len_unsafe_ptr must be non-null.
    assert_true(Int(mut_stor.len_unsafe_ptr()) != 0, "len_unsafe_ptr non-null")


fn test_ipv6_segments_roundtrip() raises:
    """Verifies that segments() returns a reference to the IpAddrV6 segments."""
    var addr = SocketAddrV6(
        0x2001, 0x0DB8, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0001,
        port=443,
    )
    var segs = addr.segments()
    assert_equal(Int(segs[0]), 0x2001, "segment 0")
    assert_equal(Int(segs[1]), 0x0DB8, "segment 1")
    assert_equal(Int(segs[7]), 0x0001, "segment 7")


fn test_addr_stor_trait() raises:
    """Smoke-test for addr_stor() and addr_stor_mut() trait implementations."""
    var addr = SocketAddrV6(0, 0, 0, 0, 0, 0, 0, 1, port=80)

    var stor = addr.addr_stor()
    assert_equal(Int(stor.addr.sin6_family), AF_INET6, "addr_stor sin6_family")

    var mut_stor = SocketAddrV6.addr_stor_mut()
    assert_equal(
        Int(mut_stor.len),
        size_of[sockaddr_in6](),
        "addr_stor_mut len",
    )


fn main() raises:
    test_ipv6_loopback_addr_stor()
    test_ipv6_addr_stor_mut_default()
    test_ipv6_segments_roundtrip()
    test_addr_stor_trait()
    print("All SocketAddrV6 tests passed.")
