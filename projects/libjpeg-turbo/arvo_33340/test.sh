#!/bin/bash
# test.sh - ALL unit tests for libjpeg-turbo (arvo_33340)
#
# This script runs the COMPLETE test suite for the libjpeg-turbo project.
# Uses cmake and ctest to build and run all 310 tests.
#
# Excluded tests (with reasons):
#   - None. All 310 tests pass.
#
# Total tests: 310
# Included: 310
# Excluded: 0
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd ${SRC:-/src}/libjpeg-turbo

# Check if cmake was already run (Makefile exists from compile.sh)
# If so, just rebuild and run tests in place
if [ -f Makefile ]; then
    echo "=== Build artifacts found, rebuilding ==="
    make -j$(nproc) 2>&1
else
    # Fresh build: configure cmake and build
    echo "=== Fresh build, configuring cmake ==="
    cmake . -DCMAKE_BUILD_TYPE=Release -DWITH_TURBOJPEG=ON 2>&1
    make -j$(nproc) 2>&1
fi

# Run all tests
echo "=== Running all libjpeg-turbo tests ==="
ctest --output-on-failure

echo "All tests passed!"
exit 0
