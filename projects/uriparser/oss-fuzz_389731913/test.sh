#!/bin/bash
# test.sh - ALL unit tests for uriparser (oss-fuzz_389731913)
#
# This script runs the COMPLETE test suite for the uriparser project.
# The test suite includes tests from 11 test suites:
#   - FourSuite: URI absolutization, relativization, parsing, and normalization tests
#   - MemoryManagerCompletenessSuite: Memory manager completeness tests
#   - MemoryManagerTestingSuite: Memory manager testing
#   - MemoryManagerTestingOverflowDetectionSuite: Overflow detection tests
#   - FailingMemoryManagerSuite: Failure handling tests
#   - UriSuite: Core URI parsing, escaping, unescaping, normalization, query handling tests
#   - ErrorPosSuite: Error position tests
#   - UriParseSingleSuite: Single URI parsing tests
#   - FreeUriMembersSuite: URI member freeing tests
#   - MakeOwnerSuite: Owner making tests
#   - ParseIpFourAddressSuite: IPv4 address parsing tests
#   - VersionSuite: Version consistency tests
#
# Total test suites: 12
# Total individual test cases: 94
# Excluded tests: 0
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

# Build gtest from source with clang (required for ABI compatibility)
cd /tmp
if [ ! -d "googletest" ]; then
    git clone --depth 1 --branch release-1.12.1 https://github.com/google/googletest.git 2>/dev/null
fi
cd googletest
rm -rf build
mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/gtest \
      -DCMAKE_C_COMPILER=/usr/local/bin/clang \
      -DCMAKE_CXX_COMPILER=/usr/local/bin/clang++ .. > /dev/null 2>&1
make -j$(nproc) > /dev/null 2>&1
make install > /dev/null 2>&1

# Build uriparser with tests enabled
cd /src/uriparser
rm -rf build_test
mkdir build_test
cd build_test
cmake .. -DURIPARSER_BUILD_TESTS=ON -DURIPARSER_BUILD_DOCS=OFF -DURIPARSER_BUILD_TOOLS=ON \
         -DCMAKE_C_COMPILER=/usr/local/bin/clang -DCMAKE_CXX_COMPILER=/usr/local/bin/clang++ \
         -DCMAKE_PREFIX_PATH=/opt/gtest \
         -DGTest_DIR=/opt/gtest/lib/cmake/GTest > /dev/null 2>&1
make -j$(nproc) > /dev/null 2>&1

# Run the full test suite
echo "Running uriparser test suite..."
ctest --output-on-failure

echo "All tests passed!"
exit 0
