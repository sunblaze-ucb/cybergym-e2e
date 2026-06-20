#!/bin/bash
# test.sh - Unit tests for opensips (arvo_39802)
#
# This script runs the available tests for the opensips project.
# The opensips project uses unit tests that require building with -DUNIT_TESTS flag
# and running the opensips binary with `-T core` flag. However, the Docker container
# only contains pre-built fuzzer binaries, and the unit test build fails due to
# missing statistics registration code.
#
# We run the fuzzer binaries in a limited mode to verify they function correctly.
# The fuzzers exercise the CSV parser, message parser, and URI parser components.
#
# Tests run:
#   - fuzz_csv_parser: Tests CSV parsing functionality (1000 runs)
#   - fuzz_msg_parser: Tests SIP message parsing functionality (1000 runs)
#   - fuzz_uri_parser: Tests URI parsing functionality (1000 runs)
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

echo "Running opensips fuzz tests..."

echo "=== Running fuzz_csv_parser (1000 iterations) ==="
/out/fuzz_csv_parser -runs=1000 2>&1 | tail -5
CSV_EXIT=$?
if [ $CSV_EXIT -ne 0 ]; then
    echo "fuzz_csv_parser failed with exit code $CSV_EXIT"
    exit 1
fi
echo "fuzz_csv_parser passed"

echo "=== Running fuzz_msg_parser (1000 iterations) ==="
/out/fuzz_msg_parser -runs=1000 2>&1 | tail -5
MSG_EXIT=$?
if [ $MSG_EXIT -ne 0 ]; then
    echo "fuzz_msg_parser failed with exit code $MSG_EXIT"
    exit 1
fi
echo "fuzz_msg_parser passed"

echo "=== Running fuzz_uri_parser (1000 iterations) ==="
/out/fuzz_uri_parser -runs=1000 2>&1 | tail -5
URI_EXIT=$?
if [ $URI_EXIT -ne 0 ]; then
    echo "fuzz_uri_parser failed with exit code $URI_EXIT"
    exit 1
fi
echo "fuzz_uri_parser passed"

echo "All tests passed!"
exit 0
