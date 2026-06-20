#!/bin/bash
# test.sh - ALL unit tests for libplist (arvo_44199)
#
# This script runs the COMPLETE test suite for the libplist project.
# Build system: autotools (make check)
#
# Total tests: 28
# Included: 28
# Excluded: 0
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/libplist

# Ensure .tarball-version exists (needed when source is from tarball, not git)
if [ ! -f .tarball-version ] && [ ! -d .git ]; then
    echo "2.2.0" > .tarball-version
fi

# Clean any previous fuzzer build and rebuild with standard compilers for testing
make clean 2>/dev/null || true
unset CC CXX CFLAGS CXXFLAGS LDFLAGS
export CC=gcc
export CXX=g++

./autogen.sh --without-cython
make -j$(nproc)

# Run the full test suite
make check

echo "All tests passed!"
exit 0
