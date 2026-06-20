#!/bin/bash
# test.sh - ALL unit tests for unit (oss-fuzz_42536348)
#
# This script runs the COMPLETE test suite for the nginx/unit project.
# The project has C unit tests that are built via ./configure --tests && make tests.
#
# Test binaries built and run:
#   - build/tests: Main test suite (random, term parse, msec diff, rbtree,
#                  mem pool, mem zone, lvlhsh, gmtime, sprintf, malloc,
#                  utf8, http parse, strverscmp, base64, clone creds tests)
#   - build/utf8_file_name_test: UTF-8 file name handling test
#   - build/ncq_test: Non-blocking concurrent queue test
#   - build/vbcq_test: Variable-size blocking concurrent queue test
#
# Excluded tests:
#   None - all tests pass
#
# Total test binaries: 4
# Included: 4
# Excluded: 0
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/unit

# Reconfigure with tests enabled (no regex since PCRE is not available)
./configure --tests --no-regex

# Build the test binaries
make tests

# Run the main test suite
echo "=== Running main test suite ==="
./build/tests

# Run additional test binaries
echo "=== Running utf8_file_name_test ==="
./build/utf8_file_name_test

echo "=== Running ncq_test ==="
./build/ncq_test

echo "=== Running vbcq_test ==="
./build/vbcq_test

echo "All tests passed!"
exit 0
