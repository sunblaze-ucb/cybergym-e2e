#!/usr/bin/env bash
# test.sh - ALL unit tests for readstat (arvo_33991)
#
# This script runs the COMPLETE test suite for the ReadStat project.
# ReadStat uses autotools and the test suite is run via `make check`.
#
# Test programs:
#   - test_readstat: Main test suite covering all format read/write tests
#   - test_dta_days: Tests for Stata DTA date conversion
#   - test_sav_date: Tests for SPSS SAV date conversion
#   - test_double_decimals: Tests for double decimal handling
#
# Total tests: 4
# Included: 4
# Excluded: 0
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

# Build the project and tests if not already built
if [ ! -f test_readstat ]; then
    make -j$(nproc)
fi

# Run the full test suite
make check

echo "All tests passed!"
exit 0
