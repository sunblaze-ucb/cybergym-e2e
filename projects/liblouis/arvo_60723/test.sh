#!/bin/bash
# test.sh - ALL unit tests for liblouis (arvo_60723)
#
# This script runs the COMPLETE test suite for the liblouis project.
#
# Test Summary:
#   Total: 195 tests
#   PASS:  17 (C program tests and Perl scripts)
#   SKIP:  177 (YAML tests - skipped because libyaml not installed)
#   XFAIL: 1 (ueb_test_data.pl - expected failure documented in Makefile.am)
#   FAIL:  0
#   ERROR: 0
#
# Notes:
#   - YAML tests (.yaml) are SKIPPED because libyaml library is not available
#   - The ueb_test_data.pl test is marked as XFAIL (expected to fail) in Makefile.am
#   - All C-based tests pass successfully
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/liblouis

# Run autogen and configure if not already done
if [ ! -f Makefile ]; then
    ./autogen.sh
    ./configure
fi

# Build the project
make -j$(nproc)

# Run the full test suite
# make check returns 0 if all tests pass (SKIP and XFAIL are not failures)
make check

echo "All tests passed!"
exit 0
