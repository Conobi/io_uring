from .ctypes import c_uint
from linux_raw.x86_64.general import *


@register_passable("trivial")
struct ReadWriteFlags:
    """`RWF_*` constants for use with `preadv2` and `pwritev2`."""

    comptime HIPRI = Self(RWF_HIPRI)
    comptime DSYNC = Self(RWF_DSYNC)
    comptime SYNC = Self(RWF_SYNC)
    comptime NOWAIT = Self(RWF_NOWAIT)
    comptime APPEND = Self(RWF_APPEND)

    var value: c_uint

    @always_inline("nodebug")
    @implicit
    fn __init__(out self, value: c_uint):
        self.value = value
