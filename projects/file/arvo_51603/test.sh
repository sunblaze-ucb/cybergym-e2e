#!/bin/bash
# test.sh - ALL unit tests for file (arvo_51603)
#
# This script runs the COMPLETE test suite for the file project.
# The "file" project is the Unix file command that determines file types.
#
# Test framework: autotools (make check)
# Total tests: 55 test files (54 regular tests + 1 basic test run)
# All tests pass - no exclusions needed.
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/file

echo "=== Building file project ==="

# Generate configure script if not present
if [ ! -f configure ]; then
    echo "Running autoreconf..."
    autoreconf -fi
fi

# Configure if Makefile not present
if [ ! -f Makefile ]; then
    echo "Running configure..."
    ./configure
fi

# Build the project
echo "Building..."
make -j$(nproc)

echo ""
echo "=== Running ALL tests for file ==="

# Run the complete test suite using make check
# This runs:
# 1. Basic test binary execution (MAGIC=../magic/magic ./test)
# 2. All 54 .testfile comparisons against their .result files
make check

echo ""
echo "All tests passed!"
exit 0
