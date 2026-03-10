# Reaction Timer — Design Spec

**Date:** 2026-03-10
**File:** `examples/reaction_timer.mojo`

## Overview

A self-contained terminal reaction timer game that demonstrates the io_uring `EventLoop` by using `submit_read` on stdin (fd 0) for async input capture.

## Game Flow

5 rounds. Each round:
1. Print "Get ready..." and sleep a random 2–5s delay (`nanosleep` raw syscall, blocking, before any ring submission)
2. Print `GO!` and record a monotonic start timestamp (`clock_gettime(CLOCK_MONOTONIC)`)
3. Submit `submit_read(STDIN_FD, buf, len, token=round_num)` on the EventLoop
4. Call `loop.poll(wait_nr=1)` — blocks until the read completes (user presses Enter)
5. In `on_complete`: compute elapsed milliseconds, store result, print it
6. After 5 rounds: print stats table (min / max / avg) and a rating string

## Architecture

### `ReactionGame(CompletionHandler)`

```
struct ReactionGame(CompletionHandler):
    results: List[Int64]   # reaction times in ms, one per round
    start_ns: Int64        # set just before submitting the read each round

    fn on_complete(mut self, token: UInt64, result: Int32, flags: IoUringCqeFlags):
        elapsed_ms = (clock_gettime_ns() - self.start_ns) / 1_000_000
        self.results.append(elapsed_ms)
        print_round_result(elapsed_ms)
```

### `main()`

```
game = ReactionGame()
loop = EventLoop(game, sq_entries=8)
buf = stack buffer [64 bytes]

print_title()
print_instructions()

for round in range(5):
    print_round_header(round + 1)
    nanosleep(random_delay_ns())    # 2–5 seconds, raw syscall
    print("GO!")
    game.start_ns = clock_gettime_ns()
    loop.submit_read(STDIN_FD, buf, 64, token=round)
    loop.poll(wait_nr=1)            # blocks until Enter pressed

print_final_stats(game.results)
```

## Key Implementation Details

- **Stdin read**: `submit_read` on fd `0` with a 64-byte stack buffer. Result content is ignored; only completion matters.
- **Timestamp**: `clock_gettime(CLOCK_MONOTONIC)` via `linux_raw` syscall wrappers.
- **Random delay**: `nanosleep` raw syscall with a seed derived from the current time.
- **Stats**: min, max, average over 5 rounds. Rating thresholds:
  - < 200ms → "Lightning fast!"
  - 200–300ms → "Sharp reflexes"
  - 300–450ms → "Human average"
  - > 450ms → "You asleep?"
- **No false-start detection**: requires raw terminal mode — out of scope.
- **sq_entries=8**: minimal ring size; only 1 op in flight at a time.

## Files

| File | Purpose |
|------|---------|
| `examples/reaction_timer.mojo` | Single-file implementation |

## Out of Scope

- False-start detection (requires raw/non-canonical terminal mode)
- Persistent leaderboard
- Network play
