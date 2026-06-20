#!/bin/bash
# test.sh - ALL unit tests for radare2 (arvo_13704)
#
# This script runs the COMPLETE unit test suite for the radare2 project.
# The tests are located in /src/radare2-regressions/unit/ and test
# various utility functions and data structures in the radare2 library.
#
# Total tests: 24
# Included: 24
# Excluded: 0
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

# Set up environment variables for ASan-compiled libraries
export PKG_CONFIG_PATH=/out/r2-static/usr/lib/pkgconfig
export LD_LIBRARY_PATH=/out/r2-static/usr/lib
export PATH=/out/r2-static/usr/bin:$PATH
export ASAN_OPTIONS=detect_leaks=0:detect_odr_violation=0
export CC='clang'
export CFLAGS='-I/out/r2-static/usr/include/libr -g -fsanitize=address,fuzzer-no-link'
export LDFLAGS='-L/out/r2-static/usr/lib -fsanitize=address,fuzzer-no-link'

# Install pkg-config if not present
apt-get update >/dev/null 2>&1 || true
apt-get install -y pkg-config >/dev/null 2>&1 || true

# Navigate to unit test directory
cd /src/radare2-regressions/unit

# Build the unit tests
make clean >/dev/null 2>&1 || true
make all >/dev/null 2>&1

# Run all unit tests
# List of all 24 unit tests:
#   test_addr_interval, test_base64, test_bitmap, test_buf, test_debruijn,
#   test_diff, test_event, test_flags, test_glob, test_hex, test_io,
#   test_list, test_queue, test_range, test_rbtree, test_skiplist,
#   test_spaces, test_sparse, test_stack, test_str, test_tree, test_unum,
#   test_util, test_vector

FAILED=0
for test in bin/test_*; do
    testname=$(basename $test)
    if $test >/dev/null 2>&1; then
        echo "PASS: $testname"
    else
        echo "FAIL: $testname"
        FAILED=1
    fi
done

if [ $FAILED -eq 0 ]; then
    echo ""
    echo "All tests passed!"
    exit 0
else
    echo ""
    echo "Some tests failed!"
    exit 1
fi
