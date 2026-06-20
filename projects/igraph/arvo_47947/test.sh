#!/bin/bash
# test.sh - ALL unit tests for igraph (arvo_47947)
#
# This script runs the COMPLETE test suite for the igraph project.
# igraph is a C library for creating and manipulating graphs.
#
# Build System: CMake with CTest
# Test Framework: CTest (CMake's test driver)
#
# Test Statistics:
#   Total: 472 | Included: 472 | Excluded: 0
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

# Build libxml2 dependency if needed
export DEPS_PATH=/src/deps
if [ ! -d "$DEPS_PATH" ]; then
    mkdir -p "$DEPS_PATH"
    cd /src/libxml2-2.9.13
    mkdir -p build && cd build
    cmake .. \
        -DCMAKE_INSTALL_PREFIX="$DEPS_PATH" \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo \
        -DLIBXML2_WITH_ICU=OFF \
        -DLIBXML2_WITH_PYTHON=OFF \
        -DLIBXML2_WITH_TESTS=OFF \
        -DLIBXML2_WITH_ZLIB=OFF \
        -DLIBXML2_WITH_LZMA=OFF > /dev/null 2>&1
    make install -j$(nproc) > /dev/null 2>&1
fi

# Build igraph with tests enabled
cd /src/igraph
mkdir -p build && cd build

cmake .. \
    -DIGRAPH_WARNINGS_AS_ERRORS=OFF \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_PREFIX_PATH="$DEPS_PATH" \
    -DBUILD_TESTING=ON \
    -DCMAKE_EXE_LINKER_FLAGS="-lpthread" > /dev/null 2>&1

# Build the test targets
make build_tests -j$(nproc) > /dev/null 2>&1

# Run the full test suite
# All 472 tests pass, no exclusions needed
ctest --output-on-failure

echo "All tests passed!"
exit 0
