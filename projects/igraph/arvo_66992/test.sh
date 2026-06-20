#!/bin/bash
# test.sh - ALL unit tests for igraph (arvo_66992)
#
# This script runs the COMPLETE test suite for the igraph project.
# The project uses CMake/CTest with 557 tests covering all modules:
# data structures, graph generators, structural properties, layout,
# community detection, flow, cliques, isomorphism, I/O, and more.
#
# Test Statistics:
#   Total tests: 557
#   Included: 557
#   Excluded: 0
#
# No tests needed to be excluded; all 557 pass on the vulnerable version.
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

cd /src/igraph

# Create version file if it does not exist (source tarball lacks git history)
if [ ! -f IGRAPH_VERSION ]; then
    echo "0.10.10" > IGRAPH_VERSION
fi

# Install build dependencies if flex/bison are missing
if ! command -v flex &> /dev/null || ! command -v bison &> /dev/null; then
    apt-get update -qq && apt-get install -y -qq flex bison libxml2-dev > /dev/null 2>&1
fi

# Clear sanitizer/fuzzer flags from compile.sh so we get a clean test build
unset CFLAGS CXXFLAGS SANITIZER_FLAGS COVERAGE_FLAGS
export CC=clang
export CXX=clang++

# Configure and build for testing in a separate directory
if [ ! -d build_test ]; then
    mkdir -p build_test
    cd build_test
    cmake .. -DBUILD_TESTING=ON -DIGRAPH_WARNINGS_AS_ERRORS=OFF -DCMAKE_BUILD_TYPE=Debug
    make -j$(nproc)
    make build_tests -j$(nproc)
    cd ..
fi

cd build_test

# Run the FULL test suite (all 557 tests)
ctest --output-on-failure --timeout 120

echo "All tests passed!"
exit 0
