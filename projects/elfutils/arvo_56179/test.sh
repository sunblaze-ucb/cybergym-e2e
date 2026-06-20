#!/usr/bin/env bash
# test.sh - ALL unit tests for elfutils (arvo_56179)
#
# This script runs the COMPLETE test suite for the elfutils project.
# elfutils uses autotools build system.
#
# IMPORTANT: compile.sh builds with sanitizers for fuzzing. For unit tests,
# we need to do a clean rebuild without sanitizer flags to avoid linker errors.
#
# Test Summary (from make check):
#   Total: 235 tests
#   Pass: 227
#   Skip: 8 (due to missing optional features like bzip2/lzma/zstd/demangle)
#   Fail: 0
#
# Skipped tests (not failures, just missing optional dependencies):
#   - run-readelf-compressed.sh: requires lzma support (disabled)
#   - run-addr2line-C-test.sh: requires C++ demangler (disabled)
#   - run-addr2line-i-demangle-test.sh: requires C++ demangler (disabled)
#   - run-backtrace-native-core.sh: requires specific core file support
#   - run-backtrace-native-core-biarch.sh: requires biarch core support
#   - run-backtrace-demangle.sh: requires C++ demangler (disabled)
#   - run-stack-demangled-test.sh: requires C++ demangler (disabled)
#   - run-lfs-symbols.sh: requires LFS symbols
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd ${SRC:-/src}/elfutils

# Clean previous build (which was built with sanitizer flags for fuzzing)
# This is necessary because compile.sh builds with MSan which causes linker
# errors when running unit tests
echo "=== Cleaning previous build ==="
make distclean 2>/dev/null || true

# Reset compiler flags to avoid sanitizer instrumentation
# Use gcc instead of clang since elfutils uses GCC-specific warning flags
unset CFLAGS
unset CXXFLAGS
unset LDFLAGS
export CC=gcc
export CXX=g++

echo "=== Configuring elfutils for unit tests ==="
autoreconf -i -f
./configure \
    --enable-maintainer-mode \
    --disable-debuginfod \
    --disable-libdebuginfod \
    --disable-demangler \
    --without-bzlib \
    --without-lzma \
    --without-zstd \
    CC=gcc \
    CXX=g++

echo "=== Building elfutils ==="
make -j$(nproc)

echo "=== Running ALL unit tests for elfutils ==="

# Run the complete test suite
make check

echo "All tests passed!"
exit 0
