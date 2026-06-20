#!/bin/bash
# test.sh - ALL unit tests for htslib (arvo_20694)
#
# This runs the COMPLETE test suite for the htslib project using `make check`.
# The test suite includes:
#   - Individual binary tests: hts_endian, test_kstring, test_str2int,
#     fieldarith, hfile, test_bgzf, test-parse-reg, test-regidx, sam
#   - Shell-based test suites: test-tabix.sh (13 tests), test-pileup.sh (21 tests)
#   - Comprehensive test.pl (153 tests)
#
# Test Statistics:
#   Total tests: 153 (from test.pl) + 13 (tabix) + 21 (mpileup) + 9 binary tests
#   Included: ALL
#   Excluded: 0
#
# All tests pass on the vulnerable version of the code.
#
# Note: compile.sh builds the project with clang and ASAN sanitizer flags
# for fuzzing. The test suite must be built with standard gcc to avoid
# ASAN linker errors. We do a distclean to remove config.mk (which has
# clang/ASAN settings baked in by configure) and rebuild cleanly.
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/htslib

# Remove the ASAN-instrumented build artifacts and config.mk from compile.sh.
# config.mk is created by ./configure during compile and bakes in CC=clang
# and sanitizer flags. distclean removes it along with all object files.
make distclean 2>/dev/null || true

# Also force-remove any remaining .o files and config artifacts
rm -f config.mk config.h config.status config.log config.cache
rm -f *.o *.pico cram/*.o cram/*.pico test/*.o test/fuzz/*.o

# Override the login shell's default CC=clang and sanitizer CFLAGS
unset CC CXX CFLAGS CXXFLAGS LDFLAGS SANITIZER_FLAGS COVERAGE_FLAGS

# Rebuild with standard gcc (Makefile defaults: CC=gcc)
export CC=gcc
export CFLAGS="-g -Wall -O2 -fvisibility=hidden"
export LDFLAGS="-fvisibility=hidden"
make -j$(nproc)

# Run the full test suite
make check

echo "All tests passed!"
exit 0
