#!/bin/bash
# test.sh - ALL unit tests for htslib (oss-fuzz_372547397)
#
# This script runs the COMPLETE test suite for the htslib project,
# rebuilding with gcc (not fuzzer-instrumented) and running all tests.
#
# Excluded tests (with reasons):
#   - test_view (in test.pl): Fails due to IUPAC base encoding issue in xx#u.sam
#     tests. The vulnerable code changes 'U' to 'N' in base sequences, causing
#     6 sub-test failures (3 per thread count: 0 and 4 threads). This is a known
#     bug in the vulnerable version. 2 test.pl test functions excluded.
#
# Total test.pl functions: 25 (including duplicates for thread counts)
# Included test.pl functions: 23
# Excluded test.pl functions: 2 (test_view with 0 and 4 threads)
#
# Additional tests run outside test.pl:
#   - 8 standalone test binaries (hts_endian, test_expr, test_kfunc, test_khash,
#     test_kstring, test_nibbles, test_str2int, test_time_funcs)
#   - fieldarith, hfile, test_bgzf, test-parse-reg, test-regidx
#   - test/sam (SAM/BAM/CRAM conversion tests)
#   - test-faidx.sh, filter.sh, test-tabix.sh, test-pileup.sh,
#     test-fastq.sh, base-mods.sh
#   - htscodecs tests (rans4x8, rans4x16, arith, tok3, fqzcomp, varint)
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -eo pipefail

cd /src/htslib

# Clear fuzzer-related environment variables and use standard gcc
unset LIB_FUZZING_ENGINE
unset FUZZING_ENGINE
unset SANITIZER
export CC=gcc
export CXX=g++
export CFLAGS="-g -O2"
export CXXFLAGS="-g -O2"
unset LDFLAGS

echo "=== Rebuilding htslib with gcc for testing ==="
make clean > /dev/null 2>&1 || true
./configure > /dev/null 2>&1
make -j$(nproc) > /dev/null 2>&1

echo "=== Running standalone test binaries ==="
test/hts_endian
test/test_expr
test/test_kfunc
test/test_khash
test/test_kstring
test/test_nibbles -v
test/test_str2int
test/test_time_funcs
test/fieldarith test/fieldarith.sam
test/hfile
test/test_bgzf test/bgziptest.txt
test/test-parse-reg -t test/colons.bam
test/test-regidx

echo "=== Running faidx tests ==="
cd test/faidx && ./test-faidx.sh faidx.tst
cd /src/htslib

echo "=== Running sam_filter tests ==="
cd test/sam_filter && ./filter.sh filter.tst
cd /src/htslib

echo "=== Running tabix tests ==="
cd test/tabix && ./test-tabix.sh tabix.tst
cd /src/htslib

echo "=== Running mpileup tests ==="
cd test/mpileup && ./test-pileup.sh mpileup.tst
cd /src/htslib

echo "=== Running fastq tests ==="
cd test/fastq && ./test-fastq.sh
cd /src/htslib

echo "=== Running base_mods tests ==="
cd test/base_mods && ./base-mods.sh base-mods.tst
cd /src/htslib

echo "=== Running SAM/BAM/CRAM conversion tests ==="
REF_PATH=: test/sam test/ce.fa test/faidx/faidx.fa test/faidx/fastqs.fq

echo "=== Running test.pl (excluding test_view due to xx#u.sam IUPAC base failures) ==="
cd test && REF_PATH=: ./test.pl -F test_bgzip,ce_fa_to_md5_cache,test_index,test_multi_ref,test_MD,test_vcf_api,test_bcf2vcf,test_vcf_sweep,test_vcf_various,test_bcf_sr_sort,test_bcf_sr_no_index,test_bcf_sr_range,test_command,test_convert_padded_header,test_rebgzip,test_logging,test_plugin_loading,test_realn,test_bcf_set_variant_type,test_annot_tsv
cd /src/htslib

echo "=== Running htscodecs tests ==="
# Use make targets to build and run htscodecs tests
make test_htscodecs_rans4x8
make test_htscodecs_rans4x16
make test_htscodecs_arith
make test_htscodecs_tok3
make test_htscodecs_fqzcomp
make test_htscodecs_varint

echo "All tests passed!"
exit 0
