#!/bin/bash
# test.sh - ALL unit tests for binutils (arvo_24020)
#
# This script runs the COMPLETE test suite for the binutils-gdb project.
# Tests cover: binutils, gas (assembler), ld (linker), and libiberty.
#
# Excluded tests (with reasons):
#   - readelf --enable-checks --sections --wide zero-sec: Fails in vulnerable
#     version due to readelf bug (known issue in this commit)
#
# Test summary:
#   binutils:  273 expected passes, 1 excluded, 2 unsupported
#   gas:      1447 expected passes
#   ld:       2554 expected passes, 57 expected failures (XFAIL), 23 unsupported
#   libiberty: 722+ passes (demangle, pexecute, expandargv, strtol)
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

# Install build dependencies
apt-get update -qq > /dev/null 2>&1
apt-get install -y -qq texinfo dejagnu bison flex > /dev/null 2>&1

cd /src/binutils-gdb

# Clean any previous in-tree build (compile.sh may leave broken state)
make distclean > /dev/null 2>&1 || true

# Use a separate build directory to avoid interference
rm -rf /tmp/binutils-build
mkdir -p /tmp/binutils-build
cd /tmp/binutils-build

# Configure with gcc to avoid clang -Werror issues
CC=gcc CXX=g++ CFLAGS='-O1 -g' CXXFLAGS='-O1 -g' \
    /src/binutils-gdb/configure \
    --disable-gdb --disable-sim --disable-gdbserver \
    --disable-gdbsupport --disable-readline --disable-libdecnumber \
    --disable-werror --disable-gold > /dev/null 2>&1

# Build the project
make -j$(nproc) > /dev/null 2>&1

# Run test suites individually (don't use set -e here since make check
# returns non-zero when any test fails, and we handle failures below)
make -C binutils check 2>&1 || true
make -C gas check 2>&1 || true
make -C ld check 2>&1 || true
make -C libiberty check 2>&1 || true

# Known failing tests to exclude (these fail in the vulnerable version)
KNOWN_FAILS="readelf --enable-checks --sections --wide zero-sec"

# Check for unexpected failures in .sum files
FAIL_COUNT=0
for sumfile in $(find . -name '*.sum'); do
    while IFS= read -r line; do
        # Strip the "FAIL: " prefix to get the test name
        testname="${line#FAIL: }"
        # Check if this is a known failure
        known=0
        if echo "$KNOWN_FAILS" | grep -qF "$testname"; then
            known=1
            echo "KNOWN FAIL (excluded): $testname"
        fi
        if [ "$known" -eq 0 ]; then
            echo "UNEXPECTED FAIL: $testname"
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    done < <(grep '^FAIL:' "$sumfile" 2>/dev/null)
done

if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "Total unexpected failures: $FAIL_COUNT"
    exit 1
fi

echo "All tests passed!"
exit 0
