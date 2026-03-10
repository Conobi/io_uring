from event_loop import EventLoop, CompletionHandler
from mojix.fd import Fd
from mojix.io_uring import IoUringCqeFlags
from mojix.ctypes import c_void
from linux_raw.x86_64.syscall import syscall
from linux_raw.x86_64.general import __kernel_timespec
from memory import UnsafePointer

comptime __NR_clock_gettime = 228
comptime __NR_nanosleep = 35
comptime CLOCK_MONOTONIC = Int32(1)
comptime STDIN_FD: Int32 = 0
comptime TOTAL_ROUNDS: Int = 5


fn clock_gettime_ns() -> Int64:
    var ts = __kernel_timespec(tv_sec=0, tv_nsec=0)
    _ = syscall[__NR_clock_gettime, Int32](
        CLOCK_MONOTONIC, UnsafePointer(to=ts)
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


struct ReactionGame(CompletionHandler):
    var results: List[Int64]
    var start_ns: Int64

    fn __init__(out self):
        self.results = List[Int64]()
        self.start_ns = 0

    fn __moveinit__(out self, deinit existing: Self):
        self.results = existing.results^
        self.start_ns = existing.start_ns

    fn on_complete(
        mut self, token: UInt64, result: Int32, flags: IoUringCqeFlags
    ):
        if result < 0:
            return
        var elapsed_ms = (clock_gettime_ns() - self.start_ns) // 1_000_000
        self.results.append(elapsed_ms)


fn rating(avg_ms: Int64) -> String:
    if avg_ms < 200:
        return "Lightning fast!"
    elif avg_ms < 300:
        return "Sharp reflexes"
    elif avg_ms < 450:
        return "Human average"
    else:
        return "You asleep?"


fn main() raises:
    print("================================")
    print("  REACTION TIMER  (io_uring)  ")
    print("================================")
    print("Press ENTER as fast as you can")
    print("when you see GO!")
    print()

    # Heap-allocated buffer — stable address required by submit_read.
    var buf = List[UInt8](length=64, fill=UInt8(0))
    var buf_ptr = UnsafePointer[c_void, StaticConstantOrigin](
        unsafe_from_address=Int(buf.unsafe_ptr())
    )

    var loop = EventLoop(ReactionGame(), sq_entries=8)

    for i in range(TOTAL_ROUNDS):
        print("Round", i + 1, "of", TOTAL_ROUNDS, "— get ready...")

        # Random delay 2–5 seconds derived from current nanoseconds.
        var seed = clock_gettime_ns()
        var delay_ns = (seed % Int64(3_000_000_000)) + Int64(2_000_000_000)
        nanosleep_ns(delay_ns)

        loop._handler.start_ns = clock_gettime_ns()
        print("GO!")
        loop.submit_read(Fd(unsafe_fd=STDIN_FD), buf_ptr, 64, UInt64(i))
        loop.poll(wait_nr=1)

        var elapsed = loop._handler.results[len(loop._handler.results) - 1]
        print("  ->", elapsed, "ms")
        print()

    # Compute stats.
    var results = loop._handler.results.copy()
    if len(results) == 0:
        print("No results recorded.")
        return
    var min_ms = results[0]
    var max_ms = results[0]
    var sum_ms: Int64 = 0
    for i in range(len(results)):
        var r = results[i]
        if r < min_ms:
            min_ms = r
        if r > max_ms:
            max_ms = r
        sum_ms += r
    var avg_ms = sum_ms // Int64(len(results))

    print("================================")
    print("           RESULTS              ")
    print("================================")
    print("  Min:", min_ms, "ms")
    print("  Max:", max_ms, "ms")
    print("  Avg:", avg_ms, "ms")
    print()
    print("  Rating:", rating(avg_ms))
    print("================================")

    _ = buf  # Keep buffer alive until after all polls.
