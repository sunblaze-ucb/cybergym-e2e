#!/bin/bash
# test.sh - ALL unit tests for igraph (arvo_29408)
#
# This script builds and runs the COMPLETE test suite for the igraph project.
# After compile.sh runs, the use_all_warnings macro is commented out in
# src/CMakeLists.txt (by build.sh), so -Werror is no longer applied.
#
# Skipped tests (by ctest, not excluded by us):
#   - tls1, tls2: Skipped by ctest (TLS not available in this build)
#
# Excluded tests: NONE
#
# Total tests: 288
# Passed: 286
# Skipped by ctest: 2 (tls1, tls2)
# Excluded: 0
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/igraph

# Build igraph with tests enabled (separate from fuzzing build)
if [ ! -d build_test ] || [ ! -f build_test/tests/test_igraph_version ]; then
    rm -rf build_test
    mkdir -p build_test
    cd build_test
    cmake .. -DBUILD_TESTING=ON
    make -j$(nproc)
    make -j$(nproc) build_tests
    cd ..
fi

cd build_test

# Run the full test suite
ctest --output-on-failure -j$(nproc)

echo "All tests passed!"
exit 0
