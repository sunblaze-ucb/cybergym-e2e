#!/bin/bash
# test.sh - ALL unit tests for htslib (arvo_18196)
#
# This runs the COMPLETE test suite for the htslib project.
# After compile.sh builds the fuzzer with sanitizer flags, we need to do a
# clean rebuild for tests since the sanitizer-instrumented build is only
# for fuzzing, not for the test suite.
#
# Test Statistics:
#   Total tests: 159
#     - tabix tests: 13 (via test-tabix.sh)
#     - mpileup tests: 21 (via test-pileup.sh)
#     - test.pl tests: ~125 (sam, vcf, cram, bcf-sr, bcf-translate, view, realn, logging, etc.)
#   Included: 159
#   Excluded: 0
#
# All 159 tests pass on the vulnerable source code without modification.
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

cd ${SRC:-/src}/htslib

# Clear sanitizer-related environment variables from compile.sh to get
# a clean build for running the test suite
unset CFLAGS CXXFLAGS LDFLAGS CC CXX SANITIZER LIB_FUZZING_ENGINE

# Clean previous build artifacts (from compile.sh sanitizer build)
make clean || true

# Regenerate configure if needed (compile.sh may have already run autoconf)
if [ ! -f configure ]; then
    autoheader
    autoconf
fi

# Reconfigure without sanitizer flags
./configure

# Build the project and all test programs
make -j$(nproc)

# Run the full test suite
make check

echo "All tests passed!"
exit 0
