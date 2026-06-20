#!/bin/bash
# test.sh - ALL unit tests for jq (arvo_64574)
#
# This script runs the COMPLETE test suite for the jq project,
# excluding only tests that genuinely fail on this version.
#
# Build system: autotools (make check)
# Tests discovered: 8 (mantest, jqtest, shtest, utf8test, base64test,
#                      optionaltest, onigtest, manonigtest)
#
# Excluded tests (with reasons):
#   - tests/shtest: Fails on NO_COLOR=1 color handling test. The test
#     expects NO_COLOR=1 to disable color output, but this version
#     still outputs ANSI color codes when NO_COLOR=1 is set.
#     (exit status 1, char 1 mismatch in color vs expect comparison)
#
# Total tests: 8
# Included: 7
# Excluded: 1

set -e

cd /src/jq

# Install build dependencies if not already present
if ! command -v autoreconf &>/dev/null; then
    apt-get update -qq && apt-get install -y -qq autoconf automake libtool bison flex > /dev/null 2>&1
fi

# Build jq if not already built
if [ ! -x /src/jq/jq ]; then
    autoreconf -fi
    ./configure --with-oniguruma=builtin --disable-docs --disable-maintainer-mode
    make -j$(nproc)
fi

# Set up environment for tests (mirrors what make check sets)
export JQ=/src/jq/jq
export NO_VALGRIND=1

# Run each passing test individually
echo "=== Running mantest ==="
./tests/mantest

echo "=== Running jqtest ==="
./tests/jqtest

echo "=== Running utf8test ==="
./tests/utf8test

echo "=== Running base64test ==="
./tests/base64test

echo "=== Running optionaltest ==="
./tests/optionaltest

echo "=== Running onigtest ==="
./tests/onigtest

echo "=== Running manonigtest ==="
./tests/manonigtest

# Excluded: tests/shtest - fails on NO_COLOR=1 color handling test

echo "All tests passed!"
exit 0
