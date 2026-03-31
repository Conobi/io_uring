#!/bin/bash
# Run all io_uring tests.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

TESTS=(
    tests/io_uring/test_nop.mojo
    tests/io_uring/test_buf.mojo
    tests/io_uring/test_net.mojo
    tests/mojix/net/test_socket.mojo
    tests/event_loop/test_event_loop.mojo
    tests/event_loop/test_event_loop_net.mojo
)

cd "$PROJECT_DIR"

PASS=0
FAIL=0

for test in "${TESTS[@]}"; do
    echo "--- Running: $test ---"
    if mojo run -I . -D ASSERT=all "$test"; then
        echo "--- PASSED: $test ---"
        PASS=$((PASS + 1))
    else
        echo "--- FAILED: $test ---"
        FAIL=$((FAIL + 1))
    fi
    echo ""
done

echo "Results: $PASS passed, $FAIL failed (out of ${#TESTS[@]})"
if [ "$FAIL" -ne 0 ]; then
    exit 1
fi
