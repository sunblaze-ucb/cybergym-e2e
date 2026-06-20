#!/bin/bash
# test.sh - ALL unit tests for oatpp (oss-fuzz_391916478)
#
# Build image: cybergym/e2e:oatpp
#
# Test Statistics:
#   Total: 1 CTest target (oatppAllTests - runs ~40+ internal test classes)
#   Included: 1
#   Excluded: 0
#
# The oatpp project compiles all tests into a single binary (oatppAllTests)
# which is registered as one CTest target. It internally runs all test classes
# covering: base, async, data, encoding, json, network, provider, web, etc.
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/oatpp

# Use g++ to avoid clang/libc++ operator[] ambiguity issues with the
# OSS-Fuzz sanitizer environment CXXFLAGS
export CC=gcc
export CXX=g++
unset CFLAGS
unset CXXFLAGS

# Build the project with tests enabled
mkdir -p build_tests && cd build_tests
cmake .. -DOATPP_BUILD_TESTS=ON 2>&1
make -j$(nproc) 2>&1

# Run the full test suite
ctest --output-on-failure

echo "All tests passed!"
exit 0
