#!/bin/bash
# test.sh - ALL unit tests for libconfig (oss-fuzz_396172337)
#
# Build image: cybergym/e2e:libconfig
#
# Test Statistics:
#   Total: 1 | Included: 1 | Excluded: 0
#
# The libconfig project has a single CTest target (libconfig_tests) that
# contains multiple test cases using the tinytest framework. All tests pass.
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/libconfig

# Build the project with tests enabled
mkdir -p build && cd build
cmake .. -DBUILD_TESTS=ON -DBUILD_EXAMPLES=OFF -DBUILD_FUZZERS=OFF 2>&1
make -j$(nproc) 2>&1

# Run the full test suite
ctest --output-on-failure

echo "All tests passed!"
exit 0
