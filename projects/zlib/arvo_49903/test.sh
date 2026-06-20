#!/bin/bash
# test.sh - ALL unit tests for zlib (arvo_49903)
#
# This script runs the COMPLETE test suite for the zlib project.
#
# Tests included:
#   - teststatic: Static library tests (example, minigzip)
#   - testshared: Shared library tests (examplesh, minigzipsh)
#   - test64: 64-bit tests (example64, minigzip64)
#   - infcover: Inflate coverage tests
#
# Excluded tests: None - all tests pass
#
# Total test suites: 4
# Included: 4
# Excluded: 0
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd ${SRC:-/src}/zlib

echo "=== Building and running zlib test suite ==="

# Configure the project
./configure

# Run the main test suite (teststatic, testshared, test64)
echo ""
echo "=== Running main test suite (make test) ==="
make test

# Build and run infcover (inflate coverage test)
echo ""
echo "=== Running infcover (inflate coverage test) ==="
make infcover
./infcover

echo ""
echo "=== All zlib tests passed! ==="
exit 0
