#!/bin/bash
# test.sh - ALL unit tests for c-blosc2 (arvo_26755)
#
# This script runs the COMPLETE test suite for the c-blosc2 project.
# It builds the project from source with tests enabled (not as a fuzzer),
# then runs all tests via ctest.
#
# Build system: CMake / CTest
# Source location: /src/c-blosc2
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

SRC_DIR="${SRC:-/src}/c-blosc2"
BUILD_DIR="${SRC_DIR}/build-test"

# Clean up any CMakeCache.txt left by the fuzzer build in the source tree
rm -f "${SRC_DIR}/CMakeCache.txt"
rm -rf "${SRC_DIR}/CMakeFiles"

# Create a separate build directory for testing
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

# Reset compiler to system default (clang-22) without sanitizer flags
export CC=clang
export CXX=clang++
unset CFLAGS CXXFLAGS LDFLAGS

# Configure with tests enabled, fuzzers/benchmarks/examples disabled
cmake "${SRC_DIR}" \
    -DBUILD_TESTS=ON \
    -DBUILD_BENCHMARKS=OFF \
    -DBUILD_FUZZERS=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DCMAKE_BUILD_TYPE=Release

# Build the project and tests
make -j$(nproc)

# Run ALL tests via ctest
ctest --output-on-failure --timeout 120

echo "All tests passed!"
exit 0
