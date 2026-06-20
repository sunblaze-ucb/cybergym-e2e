#!/bin/bash
# test.sh - ALL unit tests for c-blosc2 (arvo_34259)
#
# This script runs the COMPLETE test suite for the c-blosc2 project.
# It builds the project from source with tests enabled (not as a fuzzer),
# then runs all tests via ctest.
#
# Build system: CMake / CTest
# Source location: /src/c-blosc2
#
# Test Statistics:
#   Total tests: 1655
#   Included: 1655
#   Excluded: 0
#
# No tests are excluded - all 1655 tests pass on a clean build.
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

SRC_DIR="${SRC:-/src}/c-blosc2"
BUILD_DIR="${SRC_DIR}/build-test"

# Ensure cmake is available (should be pre-installed in the base-builder image)
if ! command -v cmake &> /dev/null; then
    apt-get update -qq && apt-get install -y -qq cmake > /dev/null 2>&1
fi

# Clean any existing cmake cache from the compile (fuzzer build) step
# which would confuse an out-of-source build
rm -f "${SRC_DIR}/CMakeCache.txt"
rm -rf "${SRC_DIR}/CMakeFiles"

# Create a separate build directory for testing
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

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
