# socketpair Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Expose the `socketpair(2)` Linux syscall through the three-layer stack (`linux_raw` → `mojix` → test), then write an E2E event loop test that sends and receives data over a Unix socketpair.

**Architecture:** Three small additive changes mirror the existing `socket`/`bind`/`listen` pattern exactly: a syscall number constant in `linux_raw`, an `AF_UNIX` constant and an internal `_socketpair` wrapper in `mojix/net`, and a public `socketpair()` function in `mojix/net/socket.mojo`. No new files are needed until the tests.

**Tech Stack:** Mojo 0.26.1, `uvx --from mojo-compiler mojo`, existing `linux_raw`/`mojix`/`io_uring`/`event_loop` packages.

---

## Background: what `socketpair(2)` does

```
int socketpair(int domain, int type, int protocol, int sv[2]);
```

Creates a pair of connected sockets and writes their file descriptors into `sv[0]` and `sv[1]`. Data written to one end is readable from the other. x86_64 syscall number is **53** (`__NR_socketpair`). `AF_UNIX = 1` is already defined in `linux_raw/x86_64/net.mojo` but not yet surfaced through `AddrFamily`.

---

## Task 1: Add syscall number constant

**Files:**
- Modify: `linux_raw/x86_64/general.mojo:7-9`

**Step 1: Add the constant after `__NR_socket`**

```mojo
comptime __NR_socket = 41
comptime __NR_socketpair = 53   # add this line
comptime __NR_bind = 49
```

**Step 2: Build to verify no regressions**

```bash
./scripts/build.sh
```
Expected: exits 0, packages built to `*.mojopkg`.

**Step 3: Commit**

```bash
git add linux_raw/x86_64/general.mojo
git commit -m "feat(linux_raw): add __NR_socketpair = 53"
```

---

## Task 2: Expose `AddrFamily.UNIX`

**Files:**
- Modify: `mojix/net/types.mojo` — find the `AddrFamily` struct (around line 250); it already has `UNSPEC` and `INET` constants

**Step 1: Add `UNIX` constant to `AddrFamily`**

The struct currently looks like:
```mojo
@register_passable("trivial")
struct AddrFamily:
    comptime UNSPEC = Self(unsafe_id=AF_UNSPEC)
    comptime INET = Self(unsafe_id=AF_INET)
    ...
```

Add `UNIX` after `UNSPEC` (both `AF_UNIX` and `AF_INET` come from `linux_raw/x86_64/net.mojo` via the wildcard import `from linux_raw.x86_64.net import *` at line 11):

```mojo
    comptime UNSPEC = Self(unsafe_id=AF_UNSPEC)
    comptime UNIX = Self(unsafe_id=AF_UNIX)     # add this line
    comptime INET = Self(unsafe_id=AF_INET)
```

**Step 2: Build**

```bash
./scripts/build.sh
```
Expected: exits 0.

**Step 3: Commit**

```bash
git add mojix/net/types.mojo
git commit -m "feat(mojix/net): expose AddrFamily.UNIX"
```

---

## Task 3: Add `_socketpair` internal wrapper + public `socketpair()`

This is the TDD task. Write the test first, watch it fail (function missing), then implement.

**Files:**
- Create: `tests/mojix/net/test_socket.mojo`
- Modify: `mojix/net/syscalls.mojo`
- Modify: `mojix/net/socket.mojo`

### Step 1: Write the failing test

Create `tests/mojix/net/test_socket.mojo`:

```mojo
from mojix.net.socket import socketpair
from mojix.net.types import AddrFamily, SocketType, SocketFlags
from testing import assert_true


fn test_socketpair_creates_connected_fds() raises:
    socketpair(
        AddrFamily.UNIX,
        SocketType.STREAM,
        out fd0,
        out fd1,
    )
    # Both fds must be non-negative valid file descriptors.
    assert_true(fd0.unsafe_fd() >= 0)
    assert_true(fd1.unsafe_fd() >= 0)
    # The two fds must be distinct.
    assert_true(fd0.unsafe_fd() != fd1.unsafe_fd())


fn main() raises:
    test_socketpair_creates_connected_fds()
```

### Step 2: Run to verify it fails

```bash
uvx --from mojo-compiler mojo run -I . -D ASSERT=all tests/mojix/net/test_socket.mojo
```
Expected: compile error — `socketpair` not defined in `mojix.net.socket`.

### Step 3: Add `_socketpair` to `mojix/net/syscalls.mojo`

Add the import at the top alongside the existing ones:

```mojo
from linux_raw.x86_64.general import __NR_socket, __NR_bind, __NR_listen, __NR_socketpair
```

Add the `DTypeArray` import (already available via `linux_raw.utils`):

```mojo
from linux_raw.utils import DTypeArray
```

Then append the new internal function after `_listen`:

```mojo
@always_inline
fn _socketpair(
    domain: AddrFamily,
    type: SocketType,
    flags: SocketFlags,
    protocol: Protocol,
    out fd0: OwnedFd[False],
    out fd1: OwnedFd[False],
) raises:
    constrained[is_x86_64()]()
    _size_eq[SocketType, c_int]()
    _size_eq[SocketFlags, c_int]()
    _size_eq[Protocol, c_int]()

    sv = DTypeArray[DType.int32, 2]()
    res = syscall[__NR_socketpair, Scalar[DType.int64]](
        UInt32(domain.id), type.id | flags.value, protocol,
        UnsafePointer(to=sv),
    )
    unsafe_decode_none(res)
    fd0 = OwnedFd[False](unsafe_fd=sv[0])
    fd1 = OwnedFd[False](unsafe_fd=sv[1])
```

### Step 4: Add public `socketpair()` to `mojix/net/socket.mojo`

Add `_socketpair` to the import at the top:

```mojo
from .syscalls import _socket, _bind, _listen, _socketpair
```

Append the public function after `listen`:

```mojo
@always_inline
fn socketpair(
    domain: AddrFamily,
    type: SocketType,
    out fd0: OwnedFd[False],
    out fd1: OwnedFd[False],
) raises:
    """Creates a pair of connected sockets.
    [Linux]: https://man7.org/linux/man-pages/man2/socketpair.2.html.
    """
    _socketpair(domain, type, SocketFlags(), Protocol(), fd0, fd1)
```

### Step 5: Run the test — verify it passes

```bash
uvx --from mojo-compiler mojo run -I . -D ASSERT=all tests/mojix/net/test_socket.mojo
```
Expected: exits 0 (no output on success).

### Step 6: Run full suite to check no regressions

```bash
./scripts/run_tests.sh
```
Expected: all existing tests still pass.

### Step 7: Commit

```bash
git add mojix/net/syscalls.mojo mojix/net/socket.mojo tests/mojix/net/test_socket.mojo
git commit -m "feat(mojix/net): add socketpair syscall wrapper"
```

---

## Task 4: E2E event loop test over a Unix socketpair

**Files:**
- Create: `tests/event_loop/test_event_loop_net.mojo`

### Step 1: Write the failing test

Create `tests/event_loop/test_event_loop_net.mojo`:

```mojo
from event_loop import EventLoop, CompletionHandler
from mojix.net.socket import socketpair
from mojix.net.types import AddrFamily, SocketType
from mojix.fd import Fd
from mojix.io_uring import IoUringCqeFlags
from mojix.ctypes import c_void
from memory import UnsafePointer
from testing import assert_equal, assert_true


alias TOKEN_SEND: UInt64 = 1
alias TOKEN_RECV: UInt64 = 2


struct NetCounter(CompletionHandler):
    var send_result: Int32
    var recv_result: Int32

    fn __init__(out self):
        self.send_result = -1
        self.recv_result = -1

    fn __moveinit__(out self, deinit existing: Self):
        self.send_result = existing.send_result
        self.recv_result = existing.recv_result

    fn on_complete(
        mut self, token: UInt64, result: Int32, flags: IoUringCqeFlags
    ):
        if token == TOKEN_SEND:
            self.send_result = result
        elif token == TOKEN_RECV:
            self.recv_result = result


fn test_send_recv_over_socketpair() raises:
    fds = socketpair(AddrFamily.UNIX, SocketType.STREAM)

    # Stack-allocate send and recv buffers.
    send_buf = String("hello")
    recv_buf = String("     ")   # 5 spaces — same length, will be overwritten

    send_ptr = UnsafePointer[c_void, StaticConstantOrigin](
        unsafe_from_address=Int(send_buf.unsafe_ptr())
    )
    recv_ptr = UnsafePointer[c_void, StaticConstantOrigin](
        unsafe_from_address=Int(recv_buf.unsafe_ptr())
    )

    loop = EventLoop(NetCounter(), sq_entries=8)
    loop.submit_send(Fd(unsafe_fd=fds[0].unsafe_fd()), send_ptr, 5, TOKEN_SEND)
    loop.submit_recv(Fd(unsafe_fd=fds[1].unsafe_fd()), recv_ptr, 5, TOKEN_RECV)
    loop.run()

    # Both ops completed.
    assert_equal(loop._handler.send_result, Int32(5))
    assert_equal(loop._handler.recv_result, Int32(5))

    # Data arrived correctly.
    assert_equal(recv_buf, send_buf)


fn main() raises:
    test_send_recv_over_socketpair()
```

### Step 2: Run to verify it fails

```bash
uvx --from mojo-compiler mojo run -I . -D ASSERT=all tests/event_loop/test_event_loop_net.mojo
```
Expected: compile error — `socketpair` not yet importable (or, if Task 3 is done, it compiles but may fail at runtime if anything is wired incorrectly).

### Step 3: Run after Task 3 is complete

After implementing Task 3, re-run the command above.
Expected: exits 0.

### Step 4: Run full suite

```bash
./scripts/run_tests.sh
```
Expected: all tests pass.

### Step 5: Commit

```bash
git add tests/event_loop/test_event_loop_net.mojo
git commit -m "test(event_loop): E2E send/recv over Unix socketpair"
```

---

## Verification Checklist

| Check | Command | Expected |
|-------|---------|----------|
| Package builds | `./scripts/build.sh` | exits 0 |
| socketpair unit test | `uvx --from mojo-compiler mojo run -I . -D ASSERT=all tests/mojix/net/test_socket.mojo` | exits 0 |
| E2E net test | `uvx --from mojo-compiler mojo run -I . -D ASSERT=all tests/event_loop/test_event_loop_net.mojo` | exits 0 |
| Full suite | `./scripts/run_tests.sh` | all pass |

---

## Key file reference

| File | Role | What changes |
|------|------|--------------|
| `linux_raw/x86_64/general.mojo:7` | x86_64 syscall numbers | Add `__NR_socketpair = 53` |
| `linux_raw/x86_64/net.mojo:11` | Already has `AF_UNIX = 1` | No change needed |
| `mojix/net/types.mojo:~252` | `AddrFamily` struct | Add `comptime UNIX = Self(unsafe_id=AF_UNIX)` |
| `mojix/net/syscalls.mojo` | Internal syscall wrappers | Add `_socketpair` |
| `mojix/net/socket.mojo` | Public net API | Add `socketpair()` |
| `tests/mojix/net/test_socket.mojo` | New unit test | Create |
| `tests/event_loop/test_event_loop_net.mojo` | New E2E test | Create |
