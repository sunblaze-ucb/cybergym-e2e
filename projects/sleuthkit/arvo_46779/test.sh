#!/usr/bin/env bash
# test.sh - Unit tests for sleuthkit (arvo_36025)
#
# This script runs the COMPLETE test suite for the sleuthkit project.
#
# Test suite consists of 2 tests (from tests/Makefile.am):
#   - runtests.sh: Tests fs_thread_test with filesystem images (SKIP - images not available)
#   - test_libraries.sh: Tests mmls with downloaded test images (PASS)
#
# Unit tests (from unit_tests/base/) are NOT available because cppunit is not installed.
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd ${SRC:-/src}/sleuthkit

# Configure and build if needed
if [ ! -f "Makefile" ]; then
    export CFLAGS="${CFLAGS} -Wno-error=non-c-typedef-for-linkage -Wno-error"
    export CXXFLAGS="${CXXFLAGS} -Wno-error=non-c-typedef-for-linkage -Wno-error"
    sed -i 's/-Werror//g' ./tsk/util/Makefile.am 2>/dev/null || true
    sed -i 's/-Werror//g' ./tsk/pool/Makefile.am 2>/dev/null || true
    ./bootstrap > /dev/null 2>&1
    ./configure --enable-static --disable-shared --disable-java --without-afflib --without-libewf --without-libvhdi --without-libvmdk > /dev/null 2>&1
fi

if [ ! -f "tsk/.libs/libtsk.a" ]; then
    make -j$(nproc) > /dev/null 2>&1
fi

echo "=== Running tests for sleuthkit ==="

# Run make check - runs the official test suite
# Expected: 2 tests total, 1 PASS (test_libraries.sh), 1 SKIP (runtests.sh)
make check

echo "All tests passed!"
exit 0
