#!/bin/bash
# test.sh - ALL unit tests for fmt (arvo_25884)
#
# Build image: gcr.io/oss-fuzz-base/base-builder@sha256:fba1033c6a64433642ab97b6ea987ddaa9938e06596c6cace1c786130fc1461b
#
# This script runs the COMPLETE test suite for the fmt project.
# The tests are built using CMake and run via ctest.
#
# Test Statistics:
#   Total tests: 17
#   Included: 17
#   Excluded: 0
#
# Test list:
#   1. assert-test
#   2. chrono-test
#   3. color-test
#   4. core-test
#   5. grisu-test
#   6. gtest-extra-test
#   7. format-test
#   8. format-impl-test
#   9. locale-test
#  10. ostream-test
#  11. compile-test
#  12. printf-test
#  13. custom-formatter-test
#  14. ranges-test
#  15. scan-test
#  16. posix-mock-test
#  17. os-test
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

# Reset compiler flags to avoid fuzzer/sanitizer flags interfering with test builds
export CC=clang
export CXX=clang++
export CFLAGS=""
export CXXFLAGS=""
export LDFLAGS=""

cd /src/fmt

# Remove any existing build directory (may have been created by compile.sh
# with a different generator like Ninja) and start fresh with Unix Makefiles
rm -rf build
mkdir build
cd build
cmake .. -DFMT_TEST=ON -DFMT_DOC=OFF -DFMT_INSTALL=OFF -DCMAKE_BUILD_TYPE=Debug 2>&1
make -j$(nproc) 2>&1

# Run all 17 tests
ctest --output-on-failure

echo "All tests passed!"
exit 0
