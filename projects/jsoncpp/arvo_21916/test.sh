#!/usr/bin/env bash
# test.sh - ALL unit tests for jsoncpp (arvo_18140)
#
# This script runs the COMPLETE test suite for the jsoncpp project.
# Tests are run with standard compilation (not ASAN/fuzzer flags) to ensure
# proper test behavior.
#
# Test suite includes:
#   - jsoncpp_readerwriter: Reader/writer integration tests (59 JSON file tests)
#   - jsoncpp_readerwriter_json_checker: JSON checker conformance tests
#   - jsoncpp_test: Unit tests (81 tests including reader, writer, value, etc.)
#
# Total tests: 3 CTest targets comprising ~140+ individual test cases
# Excluded: 0
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd ${SRC:-/src}/jsoncpp

echo "=== Running tests for jsoncpp ==="

# Build the tests in a separate directory to avoid conflicts with fuzzer build
mkdir -p build_test
cd build_test

# Configure without sanitizers/fuzzer flags for proper test execution
cmake .. \
    -DJSONCPP_WITH_TESTS=ON \
    -DCMAKE_BUILD_TYPE=Debug \
    -DJSONCPP_WITH_POST_BUILD_UNITTEST=OFF

# Build the project and test executables
make -j$(nproc)

# Run all tests
ctest --output-on-failure

echo "All tests passed!"
exit 0
