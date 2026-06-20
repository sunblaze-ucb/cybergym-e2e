#!/bin/bash
# test.sh - ALL unit tests for dav1d (arvo_60432)
#
# This script runs the COMPLETE test suite for the dav1d project.
# Tests are run from the pre-built /work/build directory.
#
# Available tests (6 total):
#   - dav1d:checkasm / checkasm      - Assembly code verification
#   - dav1d:headers / common.h_test  - Header tests
#   - dav1d:headers / data.h_test    - Header tests
#   - dav1d:headers / dav1d.h_test   - Header tests
#   - dav1d:headers / headers.h_test - Header tests
#   - dav1d:headers / picture.h_test - Header tests
#
# Excluded tests: None (all tests pass)
#
# Total tests: 6
# Included: 6
# Excluded: 0
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /work/build

echo "=== Running ALL tests for dav1d ==="

# Run the full meson test suite
meson test --print-errorlogs

echo "All tests passed!"
exit 0
