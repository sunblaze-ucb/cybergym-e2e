#!/bin/bash
# test.sh - ALL unit tests for libconfig (oss-fuzz_391975647)
#
# Build image: cybergym/e2e:libconfig
#
# Test Statistics:
#   Total: 1 ctest target (libconfig_tests binary with 16 sub-tests) | Included: 1 | Excluded: 0
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

cd /src/libconfig

# Build the project and tests with CMake
mkdir -p build && cd build
cmake .. -DBUILD_TESTS=ON > /dev/null 2>&1
make -j$(nproc) > /dev/null 2>&1

# Run the full test suite
ctest --output-on-failure

echo "All tests passed!"
exit 0
