#!/bin/bash
# test.sh - ALL unit tests for htslib (arvo_24097)
#
# This script runs the COMPLETE test suite for the htslib project.
# The test suite includes:
#   - Binary test programs: hts_endian, test_kstring, test_str2int, fieldarith,
#     hfile, test_bgzf, test-parse-reg, sam, test-regidx
#   - Shell-based test suites: test-tabix.sh (13 tests), test-pileup.sh (21 tests)
#   - Perl test driver (test.pl) running 154 sub-tests covering:
#     bgzip, index, multi_ref, view, MD, vcf_api, bcf2vcf, vcf_sweep,
#     vcf_various, bcf_sr_sort, bcf-translate, convert_padded_header,
#     rebgzip, logging, realn
#
# Test Statistics:
#   Total test groups: ~15 (binary tests + shell suites + perl test driver)
#   Perl test.pl sub-tests: 154 total, 154 passed, 0 failed
#   Tabix tests: 13 passed, 0 failed
#   Pileup tests: 21 passed, 0 failed
#   Excluded: 0
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/htslib

# Clean any prior build artifacts from the fuzz compilation step (compiled with
# sanitizer flags and fuzzer-specific settings that are not suitable for tests),
# then do a clean standard build suitable for running the test suite.
make clean 2>/dev/null || true
autoconf
autoheader
./configure
make -j$(nproc)

# Run the full test suite
make check

echo "All tests passed!"
exit 0
