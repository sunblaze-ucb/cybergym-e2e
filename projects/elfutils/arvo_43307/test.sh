#!/usr/bin/env bash

# Test script for elfutils arvo_43307 (link_map.c overflow fix)
# Uses the fuzz-dwfl-core fuzzer to exercise the dwfl_core_file_report
# code path which includes the vulnerable link_map.c:read_addrs function

set -e

FUZZER="${OUT:-/out}/fuzz-dwfl-core"
TEST_DIR="${SRC:-/src}/elfutils/tests"
FAILED=0
PASSED=0

echo "=== Running dwfl-core tests for elfutils ==="

# Verify fuzzer exists
if [ ! -x "$FUZZER" ]; then
    echo "ERROR: Fuzzer not found at $FUZZER"
    exit 1
fi

# Function to run a test
run_test() {
    local test_file="$1"
    local test_name="$2"

    if [ ! -f "$test_file" ]; then
        echo "SKIP: $test_name (file not found)"
        return 0
    fi

    echo -n "Testing $test_name... "
    if timeout 30 "$FUZZER" "$test_file" >/dev/null 2>&1; then
        echo "PASS"
        PASSED=$((PASSED + 1))
    else
        echo "FAIL (exit code: $?)"
        FAILED=$((FAILED + 1))
    fi
}

# Decompress test core files if needed
cd "$TEST_DIR"
for f in linkmap-cut.core.bz2 test-core.core.bz2 backtrace.i386.core.bz2 backtrace.x86_64.core.bz2; do
    if [ -f "$f" ] && [ ! -f "${f%.bz2}" ]; then
        bunzip2 -k "$f" 2>/dev/null || true
    fi
done

# Run tests with various core files that exercise link_map.c
echo ""
echo "--- Testing core file processing (link_map.c code paths) ---"
run_test "$TEST_DIR/linkmap-cut.core" "linkmap-cut.core"
run_test "$TEST_DIR/test-core.core" "test-core.core"
run_test "$TEST_DIR/backtrace.i386.core" "backtrace.i386.core"
run_test "$TEST_DIR/backtrace.x86_64.core" "backtrace.x86_64.core"

# Summary
echo ""
echo "=== Test Summary ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"

if [ $FAILED -eq 0 ]; then
    echo "All tests passed successfully"
    exit 0
else
    echo "Some tests failed"
    exit 1
fi
