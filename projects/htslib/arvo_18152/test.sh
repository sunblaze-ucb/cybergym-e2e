#!/bin/bash
# test.sh - ALL unit tests for htslib (arvo_18152)
#
# This script runs the COMPLETE test suite for the htslib project.
# After compile.sh runs (which builds with AFL+ASAN instrumentation),
# we need to rebuild with a standard compiler to run the test suite.
#
# The test suite includes:
#   - test/hts_endian: Endianness handling tests
#   - test/test_kstring: String utility tests
#   - test/fieldarith: Field arithmetic tests
#   - test/hfile: File I/O tests
#   - test/test_bgzf: BGZF compression tests
#   - test/test-parse-reg: Region parsing tests
#   - test/tabix/test-tabix.sh: Tabix indexing tests (13 tests)
#   - test/mpileup/test-pileup.sh: Pileup tests (21 tests)
#   - test/sam: SAM/BAM/CRAM handling tests
#   - test/test-regidx: Region index tests
#   - test/test.pl: Comprehensive integration tests (includes VCF API,
#     VCF sweep, BCF synced reader, BCF translate, view conversion,
#     bgzip round-trip, logging, realn tests)
#
# Test Statistics:
#   Total tests: 159
#   Included: 159
#   Excluded: 0
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/htslib

# Install build dependencies needed for compiling and testing
apt-get update -qq
apt-get install -y -qq autoconf zlib1g-dev libbz2-dev liblzma-dev libcurl4-openssl-dev libssl-dev 2>&1 | tail -3

# Clean the AFL+ASAN-instrumented build from compile.sh
make clean

# Reconfigure with standard gcc compiler (no sanitizers)
CC=gcc CFLAGS="-g -Wall -O2" ./configure

# Build everything including test programs
make -j$(nproc)

# Run the full test suite
make check

echo "All tests passed!"
exit 0
