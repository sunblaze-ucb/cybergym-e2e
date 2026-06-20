#!/bin/bash
# test.sh - ALL unit tests for libultrahdr (oss-fuzz_42535447)
#
# This script builds and runs the COMPLETE test suite for the libultrahdr project.
# The project uses cmake with Google Test (gtest) for unit testing.
#
# Test Suites:
#   - GainMapMathTest (52 tests)
#   - GainMapMetadataTest (1 test)
#   - IccHelperTest (2 tests)
#   - JpegDecoderHelperTest (7 tests)
#   - JpegEncoderHelperTest (4 tests)
#   - JpegRTest (8 tests)
#   - EditorAPIParameterizedTests/EditorHelperTest (parameterized, many variants)
#   - JpegRAPIParameterizedTests/JpegRAPIEncodeAndDecodeTest (parameterized, many variants)
#
# Test Statistics:
#   Total test cases: 1279
#   Passed: 1055
#   Skipped: 224 (self-skipped by gtest due to missing optional resources, not failures)
#   Failed: 0
#   Excluded: 0
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

SRC_DIR=${SRC:-/src}/libultrahdr
BUILD_DIR=/tmp/uhdr_test_build

# Build with tests enabled if the test binary does not already exist
if [ ! -f "${BUILD_DIR}/ultrahdr_unit_test" ]; then
    mkdir -p "${BUILD_DIR}"
    cd "${BUILD_DIR}"

    # Configure cmake with tests enabled, building dependencies from source.
    # Override fuzzing-related env flags with clean compiler flags.
    CC=clang CXX=clang++ \
    CFLAGS="-O1 -fno-omit-frame-pointer" \
    CXXFLAGS="-O1 -fno-omit-frame-pointer -stdlib=libc++" \
    cmake "${SRC_DIR}" \
        -DUHDR_BUILD_TESTS=ON \
        -DUHDR_BUILD_DEPS=ON \
        -DUHDR_BUILD_FUZZERS=OFF \
        -DUHDR_BUILD_EXAMPLES=OFF \
        -DCMAKE_BUILD_TYPE=Release

    # Build the unit test binary
    make -j$(nproc) ultrahdr_unit_test
fi

cd "${BUILD_DIR}"

# Run the full test suite via ctest
ctest --output-on-failure

echo "All tests passed!"
exit 0
