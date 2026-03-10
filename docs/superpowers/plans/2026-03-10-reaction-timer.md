# Reaction Timer Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A self-contained terminal reaction-timer game that uses `EventLoop.submit_read` on stdin to measure how fast the player presses Enter after seeing "GO!".

**Architecture:** A single `examples/reaction_timer.mojo` file that defines two syscall helper functions (`clock_gettime_ns`, `nanosleep_ns`), a `ReactionGame` struct implementing `CompletionHandler`, and a `main()` driving 5 rounds. Each round: random nanosleep → print GO! → `submit_read` on fd 0 → `poll(wait_nr=1)` blocks until Enter → compute elapsed ms.

**Tech Stack:** Mojo 0.26.1, `event_loop` package, `linux_raw` syscalls (`clock_gettime` nr=228, `nanosleep` nr=35), `mojix.fd.Fd`.

---

## Chunk 1: Full implementation

### Task 1: Syscall helpers — clock_gettime_ns and nanosleep_ns

**Files:**
- Create: `examples/reaction_timer.mojo`

The `clock_gettime` syscall (nr 228) takes `(clockid_t, *timespec)` and returns 0 on success.
The `nanosleep` syscall (nr 35) takes `(*timespec req, *timespec rem)` and returns 0 on success.
`__kernel_timespec` is already defined in `linux_raw.x86_64.general` as `{ tv_sec: c_longlong, tv_nsec: c_longlong }`.

- [ ] **Step 1: Create examples/reaction_timer.mojo with helper functions**

```mojo
from linux_raw.x86_64.syscall import syscall
from linux_raw.x86_64.general import __kernel_timespec
from memory import UnsafePointer

comptime __NR_clock_gettime: IntLiteral = 228
comptime __NR_nanosleep: IntLiteral = 35
comptime CLOCK_MONOTONIC: Int32 = 1


fn clock_gettime_ns() -> Int64:
    var ts = __kernel_timespec(tv_sec=0, tv_nsec=0)
    _ = syscall[__NR_clock_gettime, Int32](
        Int32(CLOCK_MONOTONIC), UnsafePointer.address_of(ts)
    )
    return ts.tv_sec * 1_000_000_000 + ts.tv_nsec


fn nanosleep_ns(ns: Int64):
    var req = __kernel_timespec(
        tv_sec=ns // 1_000_000_000, tv_nsec=ns % 1_000_000_000
    )
    var rem = __kernel_timespec(tv_sec=0, tv_nsec=0)
    _ = syscall[__NR_nanosleep, Int32](
        UnsafePointer.address_of(req), UnsafePointer.address_of(rem)
    )


fn main() raises:
    var t0 = clock_gettime_ns()
    nanosleep_ns(10_000_000)  # 10ms
    var t1 = clock_gettime_ns()
    print("elapsed (should be ~10ms):", (t1 - t0) // 1_000_000, "ms")
```

- [ ] **Step 2: Run to verify helpers work**

```bash
uvx --from mojo-compiler mojo run -I . examples/reaction_timer.mojo
```

Expected output:
```
elapsed (should be ~10ms): 10 ms
```
(value between 10–20ms is fine)

- [ ] **Step 3: Commit**

```bash
git add examples/reaction_timer.mojo
git commit -m "feat(examples): add reaction_timer scaffold with syscall helpers"
```

---

### Task 2: ReactionGame CompletionHandler

**Files:**
- Modify: `examples/reaction_timer.mojo`

`ReactionGame` stores a list of elapsed-ms results and the start timestamp that `main()` sets before each `poll`. `on_complete` computes the delta and appends it.

- [ ] **Step 4: Add ReactionGame struct and imports**

Replace the file contents with:

```mojo
from event_loop import EventLoop, CompletionHandler
from mojix.fd import Fd
from mojix.io_uring import IoUringCqeFlags
from mojix.ctypes import c_void
from linux_raw.x86_64.syscall import syscall
from linux_raw.x86_64.general import __kernel_timespec
from memory import UnsafePointer

comptime __NR_clock_gettime: IntLiteral = 228
comptime __NR_nanosleep: IntLiteral = 35
comptime CLOCK_MONOTONIC: Int32 = 1
comptime STDIN_FD: Int32 = 0
comptime TOTAL_ROUNDS: Int = 5


fn clock_gettime_ns() -> Int64:
    var ts = __kernel_timespec(tv_sec=0, tv_nsec=0)
    _ = syscall[__NR_clock_gettime, Int32](
        Int32(CLOCK_MONOTONIC), UnsafePointer.address_of(ts)
    )
    return ts.tv_sec * 1_000_000_000 + ts.tv_nsec


fn nanosleep_ns(ns: Int64):
    var req = __kernel_timespec(
        tv_sec=ns // 1_000_000_000, tv_nsec=ns % 1_000_000_000
    )
    var rem = __kernel_timespec(tv_sec=0, tv_nsec=0)
    _ = syscall[__NR_nanosleep, Int32](
        UnsafePointer.address_of(req), UnsafePointer.address_of(rem)
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
        var elapsed_ms = (clock_gettime_ns() - self.start_ns) // 1_000_000
        self.results.append(elapsed_ms)


fn main() raises:
    pass
```

- [ ] **Step 5: Compile to verify no errors**

```bash
uvx --from mojo-compiler mojo build -I . examples/reaction_timer.mojo -o /tmp/rt_check
```

Expected: exits 0, no error output.

---

### Task 3: main() — game loop and stats

**Files:**
- Modify: `examples/reaction_timer.mojo`

The buffer must be heap-allocated (following the test pattern from `test_event_loop_net.mojo`) because `UnsafePointer[c_void, StaticConstantOrigin]` requires a stable address. The `StaticConstantOrigin` is needed by `submit_read`'s signature — construct it via `unsafe_from_address=Int(list.unsafe_ptr())`.

- [ ] **Step 6: Replace main() with full game loop**

```mojo
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
        var delay_ns = (seed % 3_000_000_000) + 2_000_000_000
        nanosleep_ns(delay_ns)

        print("GO!")
        loop._handler.start_ns = clock_gettime_ns()
        loop.submit_read(Fd(unsafe_fd=STDIN_FD), buf_ptr, 64, UInt64(i))
        loop.poll(wait_nr=1)

        var elapsed = loop._handler.results[i]
        print("  ->", elapsed, "ms")
        print()

    # Compute stats.
    var results = loop._handler.results
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
    var avg_ms = sum_ms // TOTAL_ROUNDS

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
```

- [ ] **Step 7: Run the game end-to-end**

```bash
uvx --from mojo-compiler mojo run -I . examples/reaction_timer.mojo
```

Play 5 rounds. Verify:
- Each round waits 2–5 seconds before printing GO!
- Reaction time prints immediately after pressing Enter
- Final stats table shows correct min/max/avg
- Rating string matches avg threshold

- [ ] **Step 8: Commit**

```bash
git add examples/reaction_timer.mojo
git commit -m "feat(examples): add reaction timer game using io_uring EventLoop"
```

---

### Notes for the implementer

**Syscall pointer args:** `UnsafePointer.address_of(ts)` where `ts` is a local `var` of type `__kernel_timespec`. The pointer type (`UnsafePointer[__kernel_timespec]`) satisfies `AnyTrivialRegType` since pointers are register-passable. If the compiler rejects this, try passing `Int(UnsafePointer.address_of(ts))` — casting to `Int` is always safe for syscall args.

**`StaticConstantOrigin` buffer pointer:** Follow exactly the cast pattern from `tests/event_loop/test_event_loop_net.mojo`:
```mojo
UnsafePointer[c_void, StaticConstantOrigin](unsafe_from_address=Int(buf.unsafe_ptr()))
```

**Accessing `loop._handler`:** `_handler` is a public struct field on `EventLoop`. Accessing `loop._handler.start_ns = ...` before each poll is intentional — the handler is part of the loop's state.

**Random distribution:** `seed % 3_000_000_000 + 2_000_000_000` gives nanosecond delays uniformly between 2s and 5s. The seed changes every round because `clock_gettime_ns()` is called fresh each time.
