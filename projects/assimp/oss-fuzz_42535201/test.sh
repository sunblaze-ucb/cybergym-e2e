#!/bin/bash
# test.sh - ALL unit tests for assimp (oss-fuzz_42535201)
#
# This script runs the COMPLETE Google Test suite for the assimp project.
# The original build in the container was configured for fuzzing (libfuzzer + ASAN)
# with ASSIMP_BUILD_TESTS=OFF, so we do a separate clean build with tests enabled
# in /tmp/assimp_build.
#
# Test Statistics:
#   Total tests: 582 (Google Test cases in the "unit" binary)
#   Included: 582
#   Excluded: 0
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

SRC_DIR=/src/assimp
BUILD_DIR=/tmp/assimp_build

# Clean any previous test build
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Remove old CMake cache from source dir to avoid conflicts
rm -f "$SRC_DIR/CMakeCache.txt"
rm -rf "$SRC_DIR/CMakeFiles"

# Configure a clean build with tests enabled and without sanitizer flags
cd "$BUILD_DIR"
cmake "$SRC_DIR" \
  -G Ninja \
  -DCMAKE_C_COMPILER=/usr/local/bin/clang \
  -DCMAKE_CXX_COMPILER=/usr/local/bin/clang++ \
  -DCMAKE_C_FLAGS="" \
  -DCMAKE_CXX_FLAGS="-stdlib=libc++" \
  -DCMAKE_BUILD_TYPE=Release \
  -DASSIMP_BUILD_TESTS=ON \
  -DASSIMP_BUILD_ASSIMP_TOOLS=OFF \
  -DASSIMP_BUILD_SAMPLES=OFF \
  -DBUILD_SHARED_LIBS=ON \
  -DASSIMP_WARNINGS_AS_ERRORS=OFF \
  -DASSIMP_BUILD_ZLIB=ON

# Build everything
ninja -j$(nproc)

# Run the full test suite
# The test binary is at bin/unit and needs the shared library path set
cd "$BUILD_DIR"
LD_LIBRARY_PATH="$BUILD_DIR/bin" ./bin/unit

echo "All tests passed!"
exit 0
