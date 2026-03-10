#!/bin/bash

set -e

TESTS=(
    tests/io_uring/test_nop.mojo
    tests/io_uring/test_buf.mojo
    tests/io_uring/test_net.mojo
    tests/mojix/net/test_socket.mojo
    tests/event_loop/test_event_loop.mojo
    tests/event_loop/test_event_loop_net.mojo
)

PASS=0
FAIL=0

for test in "${TESTS[@]}"; do
    echo "Running $test ..."
    if uvx --from mojo-compiler mojo run -I . -D ASSERT=all "$test"; then
        echo "  PASSED: $test"
        PASS=$((PASS + 1))
    else
        echo "  FAILED: $test"
        FAIL=$((FAIL + 1))
    fi
done

echo ""
echo "Results: $PASS passed, $FAIL failed"

if [ "$FAIL" -ne 0 ]; then
    exit 1
fi
