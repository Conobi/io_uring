# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Build all packages
./scripts/build.sh

# Run all tests
./scripts/run_tests.sh

# Run a single test file
uvx --from mojo-compiler mojo run -I . -D ASSERT=all tests/io_uring/test_nop.mojo
```

Build packages individually:
```bash
uvx --from mojo-compiler mojo package linux_raw -o linux_raw.mojopkg
uvx --from mojo-compiler mojo package mojix -o mojix.mojopkg
uvx --from mojo-compiler mojo package io_uring -o io_uring.mojopkg
```

## Architecture

Three-layer abstraction:

**`linux_raw/`** — Raw Linux syscall bindings for x86_64. Contains C type aliases, errno codes, raw `io_uring` structs (`IoUringParams`, `Sqe`, `Cqe`), and direct syscall wrappers. Architecture-specific code lives in `linux_raw/x86_64/`.

**`mojix/`** — Safe I/O wrappers over `linux_raw`. Defines file descriptor traits (`UnsafeFileDescriptor`, `FileDescriptor`, `IoUringFileDescriptor`), network helpers (`net/`), and error handling via `Errno`.

**`io_uring/`** — High-level async I/O ring. The main type is `IoUring[sqe, cqe, polling, is_registered]` (default: `IoUring[SQE64, CQE16, NOPOLL, is_registered=True]`), defined in `qp.mojo`. Key submodules:
- `sq.mojo` / `cq.mojo` — memory-mapped ring queue implementations with atomic head/tail
- `op.mojo` — fluent operation builders (`Nop`, `Accept`, `Read`, `Write`, `Send`, etc.)
- `buf.mojo` — ring-mapped buffer support (`BufRing`)
- `modes.mojo` — polling modes (`NOPOLL`, `IOPOLL`); `SQPOLL` is defined but disabled (Mojo lacks atomic fence support)

`__init__.mojo` re-exports: `linux_raw` exports nothing (import submodules directly); `mojix` exports only `sigset_t`; `io_uring` exports `IoUring`, `Params`, `WaitArg`.

## Key Patterns

- **Generics for performance tuning**: Entry sizes (SQE64/SQE128, CQE16/CQE32) and polling mode are compile-time parameters on `IoUring`.
- **RAII file descriptors**: `OwnedFd[is_registered]` auto-closes on destruction; registered FDs go through io_uring's registered file table.
- **Operation builder pattern**: Op types use method chaining and return `Self` for ergonomic SQE construction.
- **Origin system**: Mojo's borrow checker (`MutableOrigin`, `ImmutableOrigin`) is used throughout for memory safety without GC.
- **WaitArg**: `WaitArg[sigmask_origin, timespec_origin]` wraps an optional signal mask and `Timespec` timeout for `ring.cq(wait_nr=N)` calls; convert via `.as_enter_arg()`.

## Environment

Requires `uv` with `mojo-compiler` tool (`uvx --from mojo-compiler mojo`). Pinned to Mojo 0.26.1 via `.mojo-version`. Only x86_64 Linux is supported.
