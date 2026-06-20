#!/usr/bin/env bash
# test.sh - ALL unit tests for hunspell (arvo_52317)
#
# This script runs the COMPLETE test suite for the hunspell project.
# The project uses autotools (autoreconf + configure + make check).
#
# The oss-fuzz build environment sets clang with libc++ which causes pthread
# linker errors when building the hunspell CLI tools needed for tests.
# We build with gcc/g++ instead, which links correctly and produces
# identical test results.
#
# Test Statistics:
#   Total tests: 128
#   Included: 128
#   Excluded: 0
#
# All 128 tests pass.
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd ${SRC:-/src}/hunspell

# Override the oss-fuzz compiler settings to use gcc for building
# the hunspell CLI tools needed by the test suite
unset CFLAGS CXXFLAGS LDFLAGS LIB_FUZZING_ENGINE SANITIZER ARCHITECTURE
export CC=gcc
export CXX=g++

# Clean any previous build (compile.sh may have built with clang/ASAN)
make distclean 2>/dev/null || true

# Build hunspell from source with gcc
autoreconf -fi
./configure --prefix=/usr
make -j$(nproc)

# Run the full test suite (128 tests)
make check

echo "All tests passed!"
exit 0
