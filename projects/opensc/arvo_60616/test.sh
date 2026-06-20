#!/bin/bash
# test.sh - ALL unit tests for opensc (arvo_45552)
#
# This script runs the COMPLETE test suite for the OpenSC project.
#
# Test Statistics:
#   Unit tests (src/tests/unittests/): 8 tests (asn1, simpletlv, cachedir,
#     pkcs15filter, openpgp-tool, hextobin, compression, sm)
#   Integration tests (tests/): 8 tests - 2 run (test-manpage.sh,
#     test-duplicate-symbols.sh), 5 skip (require SoftHSM2 hardware),
#     1 expected failure (test-pkcs11-tool-test-threads.sh)
#
# Total: 16 tests | Pass: 10 | Skip: 5 | XFAIL: 1
#
# Excluded tests (with reasons):
#   - test-pkcs11-tool-sign-verify.sh: SKIP - Requires SoftHSM2 hardware
#   - test-pkcs11-tool-test.sh: SKIP - Requires SoftHSM2 hardware
#   - test-pkcs11-tool-test-threads.sh: XFAIL - Expected failure (requires hardware)
#   - test-pkcs11-tool-allowed-mechanisms.sh: SKIP - Requires SoftHSM2 hardware
#   - test-pkcs11-tool-sym-crypt-test.sh: SKIP - Requires SoftHSM2 hardware
#   - test-pkcs11-tool-unwrap-wrap-test.sh: SKIP - Requires SoftHSM2 hardware
#
# Exit codes:
#   0 - All tests passed (or skipped/expected failure)
#   1 - One or more tests failed

set -e

# Install CMOCKA if not already installed (needed for unit tests)
if ! dpkg -s libcmocka-dev >/dev/null 2>&1; then
    echo "Installing libcmocka-dev..."
    apt-get update -qq
    apt-get install -y -qq libcmocka-dev
fi

cd /src/opensc

# Clean any previous build to avoid conflicts with fuzzing build
echo "Cleaning previous build..."
make distclean 2>/dev/null || true

# Bootstrap and configure the project
echo "Bootstrapping OpenSC..."
./bootstrap

echo "Configuring OpenSC..."
./configure --disable-pcsc --enable-ctapi

# Build the project
echo "Building OpenSC..."
make -j$(nproc)

# Run all tests
echo "Running all unit tests..."
make check

echo "All tests passed!"
exit 0
