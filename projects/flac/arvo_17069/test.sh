#!/bin/bash
# test.sh - ALL unit tests for flac (arvo_17069)
#
# This script runs the COMPLETE test suite for the flac project,
# excluding only tests that genuinely fail in the Docker environment.
#
# Excluded tests (with reasons):
#   - test_libFLAC.sh: Fails because Docker runs as root; the metadata
#     manipulation test checks that a read-only file is not writable,
#     but root can always write to files, causing the test to fail.
#   - test_libFLAC++.sh: Same root permission issue as test_libFLAC.sh.
#
# Total test scripts: 9
# Included: 7
# Excluded: 2
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

export ASAN_OPTIONS="detect_leaks=0"
export FLAC__TEST_LEVEL=0

cd /src/flac

# Build test programs (they may not have been built during fuzzer compilation)
make -j$(nproc) check -k 2>/dev/null || true

cd /src/flac/test

# Run all passing test scripts
echo "=== Running test_grabbag.sh ==="
./test_grabbag.sh

echo "=== Running test_streams.sh ==="
./test_streams.sh

echo "=== Running test_flac.sh ==="
./test_flac.sh

echo "=== Running test_metaflac.sh ==="
./test_metaflac.sh

echo "=== Running test_replaygain.sh ==="
./test_replaygain.sh

echo "=== Running test_seeking.sh ==="
./test_seeking.sh

echo "=== Running test_compression.sh ==="
./test_compression.sh

echo "All tests passed!"
exit 0
