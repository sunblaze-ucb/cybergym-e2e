#!/bin/bash
# test.sh - ALL unit tests for libtpms (arvo_65530)
#
# This script runs the COMPLETE test suite for the libtpms project.
# Only tests that genuinely fail are excluded.
#
# Excluded tests (with reasons):
#   - fuzz.sh: Requires libFuzzingEngine.a which is not available in this container
#              The fuzz binary cannot be built without the fuzzing engine library.
#
# Available tests (from tests/Makefile.am with TPM2 enabled):
#   - base64decode.sh (INCLUDED)
#   - nvram_offsets (INCLUDED)
#   - tpm2_createprimary.sh (INCLUDED)
#   - tpm2_cve-2023-1017.sh (INCLUDED)
#   - tpm2_cve-2023-1018.sh (INCLUDED)
#   - tpm2_pcr_read.sh (INCLUDED)
#   - tpm2_selftest.sh (INCLUDED)
#   - fuzz.sh (EXCLUDED - requires fuzzing engine)
#
# Total tests: 8
# Included: 7
# Excluded: 1
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/libtpms

# Configure and build if not already done
if [ ! -f Makefile ]; then
    ./autogen.sh --prefix=/usr --with-tpm2 --with-openssl
fi

make -j$(nproc)

# Build test programs (except fuzz which requires fuzzing engine)
cd tests
make base64decode nvram_offsets tpm2_createprimary tpm2_cve-2023-1017 tpm2_cve-2023-1018 tpm2_pcr_read tpm2_selftest

echo "=== Running base64decode.sh ==="
./base64decode.sh

echo "=== Running nvram_offsets ==="
./nvram_offsets

echo "=== Running tpm2_selftest.sh ==="
./tpm2_selftest.sh

echo "=== Running tpm2_createprimary.sh ==="
./tpm2_createprimary.sh

echo "=== Running tpm2_pcr_read.sh ==="
./tpm2_pcr_read.sh

echo "=== Running tpm2_cve-2023-1017.sh ==="
./tpm2_cve-2023-1017.sh

echo "=== Running tpm2_cve-2023-1018.sh ==="
./tpm2_cve-2023-1018.sh

echo "All tests passed!"
exit 0
