from std.sys.info import size_of
from linux_raw.x86_64.net import (
    iovec,
    msghdr,
    cmsghdr,
    in_pktinfo,
    in6_pktinfo,
)
from std.testing import assert_equal


fn test_struct_sizes() raises:
    # Sizes verified against C: gcc -D_GNU_SOURCE validate_udp_structs.c
    assert_equal(size_of[iovec](), 16, "iovec must be 16 bytes")
    assert_equal(size_of[msghdr](), 56, "msghdr must be 56 bytes")
    assert_equal(size_of[cmsghdr](), 16, "cmsghdr must be 16 bytes")
    assert_equal(size_of[in_pktinfo](), 12, "in_pktinfo must be 12 bytes")
    assert_equal(size_of[in6_pktinfo](), 20, "in6_pktinfo must be 20 bytes")


fn main() raises:
    test_struct_sizes()
    print("All struct size assertions passed.")
