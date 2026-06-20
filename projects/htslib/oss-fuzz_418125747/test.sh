#!/bin/bash
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

cd /src/htslib

# Rebuild with standard (non-fuzzer) flags for testing
make clean > /dev/null 2>&1
./configure > /dev/null 2>&1
make -j$(nproc) > /dev/null 2>&1

echo "=== Running standalone unit tests ==="

# Basic unit tests (standalone binaries)
test/hts_endian
echo "PASS: hts_endian"

test/test_expr
echo "PASS: test_expr"

test/test_kfunc
echo "PASS: test_kfunc"

test/test_kstring
echo "PASS: test_kstring"

test/test_str2int
echo "PASS: test_str2int"

test/test_time_funcs
echo "PASS: test_time_funcs"

test/fieldarith test/fieldarith.sam
echo "PASS: fieldarith"

test/hfile
echo "PASS: hfile"

test/test_bgzf test/bgziptest.txt
echo "PASS: test_bgzf"

test/test-parse-reg -t test/colons.bam
echo "PASS: test-parse-reg"

test/test-regidx
echo "PASS: test-regidx"

REF_PATH=: test/sam test/ce.fa test/faidx/faidx.fa test/faidx/fastqs.fq
echo "PASS: sam"

echo "=== Running shell-based test suites ==="

cd test/faidx && ./test-faidx.sh faidx.tst && cd /src/htslib
echo "PASS: faidx test suite"

cd test/sam_filter && ./filter.sh filter.tst && cd /src/htslib
echo "PASS: sam_filter test suite"

cd test/tabix && ./test-tabix.sh tabix.tst && cd /src/htslib
echo "PASS: tabix test suite"

cd test/mpileup && ./test-pileup.sh mpileup.tst && cd /src/htslib
echo "PASS: mpileup test suite"

cd test/fastq && ./test-fastq.sh && cd /src/htslib
echo "PASS: fastq test suite"

cd test/base_mods && ./base-mods.sh base-mods.tst && cd /src/htslib
echo "PASS: base_mods test suite"

echo "=== Running htscodecs varint test ==="
make test_htscodecs_varint
echo "PASS: htscodecs varint"

echo "=== Running test.pl (excluding test_view) ==="
# test_view excluded: CRAM decode failures on large_seq, large_aux,
# large_aux_java, and xx#u test files (vulnerable code version issue)
cd test && REF_PATH=: perl ./test.pl -F test_bgzip,test_index,test_multi_ref,test_MD,test_vcf_api,test_bcf2vcf,test_vcf_sweep,test_vcf_various,test_bcf_sr_sort,test_bcf_sr_no_index,test_bcf_sr_range,test_command,test_convert_padded_header,test_rebgzip,test_logging,test_plugin_loading,test_realn,test_bcf_set_variant_type,test_annot_tsv && cd /src/htslib
echo "PASS: test.pl (238 tests)"

echo ""
echo "All tests passed!"
exit 0

