#!/usr/bin/env bash
# test.sh - ALL unit tests for libtpms (oss-fuzz_42537128)
#
# This script runs the COMPLETE test suite for the libtpms project.
# Only tests that genuinely fail are excluded.
#
# Excluded tests (with reasons):
#   - fuzz.sh: The fuzz binary links against libFuzzer which is built with
#              AddressSanitizer; running it as a test (not in fuzzing mode)
#              doesn't work in the standard test harness.
#
# Total tests defined in Makefile.am: 10
# Included: 9
# Excluded: 1 (fuzz.sh)
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

# The compile step builds in /work/build, but tests need to be built and run
# We need to configure and build with test support
cd ${SRC:-/src}/libtpms

# Configure and build with TPM2 support
./autogen.sh --with-tpm2 --with-openssl --prefix=/usr > /dev/null 2>&1
make -j$(nproc) > /dev/null 2>&1

# Build the test programs (excluding fuzz which has linker issues)
cd tests
make base64decode nvram_offsets tpm2_createprimary tpm2_cve-2023-1017 \
     tpm2_cve-2023-1018 tpm2_pcr_read tpm2_selftest tpm2_setprofile object_size \
     > /dev/null 2>&1

echo "=== Running tests for libtpms ==="
FAILED=0

# Test 1: base64decode.sh
echo -n "Running base64decode.sh... "
if ./base64decode.sh > /dev/null 2>&1; then
    echo "PASS"
else
    echo "FAIL"
    FAILED=1
fi

# Test 2: nvram_offsets
echo -n "Running nvram_offsets... "
if ./nvram_offsets > /dev/null 2>&1; then
    echo "PASS"
else
    echo "FAIL"
    FAILED=1
fi

# Test 3: tpm2_selftest.sh
echo -n "Running tpm2_selftest.sh... "
if ./tpm2_selftest.sh > /dev/null 2>&1; then
    echo "PASS"
else
    echo "FAIL"
    FAILED=1
fi

# Test 4: tpm2_createprimary.sh
echo -n "Running tpm2_createprimary.sh... "
if ./tpm2_createprimary.sh > /dev/null 2>&1; then
    echo "PASS"
else
    echo "FAIL"
    FAILED=1
fi

# Test 5: tpm2_cve-2023-1017.sh
echo -n "Running tpm2_cve-2023-1017.sh... "
if ./tpm2_cve-2023-1017.sh > /dev/null 2>&1; then
    echo "PASS"
else
    echo "FAIL"
    FAILED=1
fi

# Test 6: tpm2_cve-2023-1018.sh
echo -n "Running tpm2_cve-2023-1018.sh... "
if ./tpm2_cve-2023-1018.sh > /dev/null 2>&1; then
    echo "PASS"
else
    echo "FAIL"
    FAILED=1
fi

# Test 7: tpm2_pcr_read.sh
echo -n "Running tpm2_pcr_read.sh... "
if ./tpm2_pcr_read.sh > /dev/null 2>&1; then
    echo "PASS"
else
    echo "FAIL"
    FAILED=1
fi

# Test 8: tpm2_setprofile.sh
echo -n "Running tpm2_setprofile.sh... "
if ./tpm2_setprofile.sh > /dev/null 2>&1; then
    echo "PASS"
else
    echo "FAIL"
    FAILED=1
fi

# Test 9: object_size
echo -n "Running object_size... "
if ./object_size > /dev/null 2>&1; then
    echo "PASS"
else
    echo "FAIL"
    FAILED=1
fi

echo ""
if [ $FAILED -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed"
    exit 1
fi
