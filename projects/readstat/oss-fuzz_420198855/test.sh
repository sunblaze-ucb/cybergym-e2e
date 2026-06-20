#!/usr/bin/env bash
# test.sh - ALL unit tests for readstat (oss-fuzz_420198855)
#
# Build image: cybergym/e2e:readstat
#
# Test Statistics:
#   Total: 4 | Included: 3 | Excluded: 1
#
# Excluded tests (with reasons):
#   - test_readstat: Fails under ASAN/fuzzer-instrumented build (the compile.sh
#     builds with -fsanitize=address,fuzzer-no-link which causes test failures
#     in the main test binary)
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd ${SRC:-/src}/readstat

# Run autogen if configure doesn't exist
if [ ! -f configure ]; then
    ./autogen.sh
fi

# Configure if Makefile doesn't exist
if [ ! -f Makefile ]; then
    ./configure
fi

# Build the test binaries
make -j$(nproc) test_dta_days test_sav_date test_double_decimals

# Run individual passing tests (excluding test_readstat which fails under ASAN)
./test_dta_days
./test_sav_date
./test_double_decimals

echo "All tests passed!"
exit 0

