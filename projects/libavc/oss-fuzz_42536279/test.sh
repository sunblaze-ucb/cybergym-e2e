#!/usr/bin/env bash
# test.sh - ALL unit tests for libavc (oss-fuzz_42536279)
#
# This runs the COMPLETE test suite for the libavc project.
# The only test suite available is AvcEncTest (Google Test based encoder tests).
#
# Build system: CMake with -DENABLE_TESTS=1 -DENABLE_SVC=1 -DENABLE_MVC=1
# Test framework: Google Test (downloaded via ExternalProject)
# Test resources: Downloaded from dl.google.com/android-unittest
#
# Test Statistics:
#   Total tests: 2
#   Included: 2
#   Excluded: 0
#
# Test cases:
#   - EncodeTest/AvcEncTest.EncodeTest/0: Encode bbb_352x288_420p_30fps_32frames.yuv
#   - EncodeTest/AvcEncTest.EncodeTest/1: Encode football_qvga.yuv
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

SRC_DIR="${SRC:-/src}"
LIBAVC_DIR="${SRC_DIR}/libavc"
BUILD_DIR="${LIBAVC_DIR}/build_test"
RES_DIR="/tmp/AvcTestRes/AvcTestRes-1.0"

echo "=== Building libavc with tests enabled ==="

# Create build directory (cmake requires out-of-source build)
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

# Configure with tests, SVC, and MVC enabled
cmake "${LIBAVC_DIR}" \
    -DENABLE_TESTS=1 \
    -DENABLE_SVC=1 \
    -DENABLE_MVC=1 \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DCMAKE_BUILD_TYPE=Release 2>&1

# Build the project and tests
make -j"$(nproc)" 2>&1

echo "=== Downloading test resources ==="

# Download and extract test resource files if not already present
if [ ! -d "${RES_DIR}" ]; then
    mkdir -p /tmp/AvcTestRes
    wget -q "https://dl.google.com/android-unittest/media/external/libavc/tests/AvcTestRes-1.0.zip" \
        -O /tmp/AvcTestRes.zip
    unzip -o /tmp/AvcTestRes.zip -d /tmp/AvcTestRes
fi

echo "=== Running AvcEncTest (full test suite) ==="

# Run the complete Google Test suite with test resources
"${BUILD_DIR}/AvcEncTest" -P "${RES_DIR}/"

echo "All tests passed!"
exit 0
