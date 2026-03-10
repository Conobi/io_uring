from linux_raw.x86_64.syscall import syscall
from linux_raw.x86_64.general import __kernel_timespec
from memory import UnsafePointer

comptime __NR_clock_gettime = 228
comptime __NR_nanosleep = 35
comptime CLOCK_MONOTONIC = Int32(1)


fn clock_gettime_ns() -> Int64:
    var ts = __kernel_timespec(tv_sec=0, tv_nsec=0)
    _ = syscall[__NR_clock_gettime, Int32](
        Int32(CLOCK_MONOTONIC), UnsafePointer(to=ts)
    )
    return ts.tv_sec * 1_000_000_000 + ts.tv_nsec


fn nanosleep_ns(ns: Int64):
    var req = __kernel_timespec(
        tv_sec=ns // 1_000_000_000, tv_nsec=ns % 1_000_000_000
    )
    var rem = __kernel_timespec(tv_sec=0, tv_nsec=0)
    _ = syscall[__NR_nanosleep, Int32](
        UnsafePointer(to=req), UnsafePointer(to=rem)
    )


fn main() raises:
    var t0 = clock_gettime_ns()
    nanosleep_ns(10_000_000)  # 10ms
    var t1 = clock_gettime_ns()
    print("elapsed (should be ~10ms):", (t1 - t0) // 1_000_000, "ms")
