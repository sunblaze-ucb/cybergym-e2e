#!/bin/bash
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

SRC_DIR="${SRC:-/src}/libavc"
BUILD_DIR="/tmp/libavc_test_build"
RES_DIR="/tmp/testres"

# ------------------------------------------------------------------
# Step 1: Install dependencies and download test resource files
# ------------------------------------------------------------------
apt-get update -qq > /dev/null 2>&1 && apt-get install -y -qq unzip > /dev/null 2>&1

mkdir -p "$RES_DIR"
wget -q "https://dl.google.com/android-unittest/media/external/libavc/tests/AvcTestRes-1.0.zip" \
    -O "$RES_DIR/AvcTestRes.zip"
unzip -o "$RES_DIR/AvcTestRes.zip" -d "$RES_DIR/" > /dev/null 2>&1

# ------------------------------------------------------------------
# Step 2: Build the project with tests enabled (out-of-source build)
# ------------------------------------------------------------------
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

export CFLAGS="-O1 -fno-omit-frame-pointer -gline-tables-only"
export CXXFLAGS="-O1 -fno-omit-frame-pointer -gline-tables-only"
export LDFLAGS=""
unset LIB_FUZZING_ENGINE

echo "=== Configuring cmake build ==="
cmake "$SRC_DIR" \
    -DENABLE_TESTS=ON \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DCMAKE_BUILD_TYPE=Debug \
    > /dev/null 2>&1

echo "=== Building AvcEncTest ==="
make -j"$(nproc)" AvcEncTest > /dev/null 2>&1

# ------------------------------------------------------------------
# Step 3: Run the full GTest test suite
# ------------------------------------------------------------------
echo "=== Running AvcEncTest ==="
"$BUILD_DIR/AvcEncTest" -P "$RES_DIR/AvcTestRes-1.0/"

echo "All tests passed!"
exit 0

