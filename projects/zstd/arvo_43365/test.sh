#!/usr/bin/env bash
# test.sh - ALL unit tests for zstd (arvo_43365)
#
# This script runs the COMPLETE test suite for the zstd project.
# Tests included:
#   - poolTests: Thread pool tests
#   - invalidDictionaries: Dictionary validation tests
#   - legacy: Legacy format compatibility tests
#   - fullbench: Benchmark tests (verifies compression/decompression works)
#   - fuzzer: Fuzz tests (short duration for validation)
#   - zstreamtest: Streaming API fuzz tests (short duration for validation)
#   - decodecorpus: Decode corpus tests
#   - playTests.sh: Main zstd CLI test suite
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd ${SRC:-/src}/zstd

# Build the zstd binary if needed
echo "=== Building zstd ==="
make -j4 zstd-release

# Build test binaries
echo "=== Building test binaries ==="
cd tests
make -j4 datagen fullbench fuzzer zstreamtest poolTests invalidDictionaries legacy decodecorpus

echo ""
echo "=== Running poolTests ==="
./poolTests

echo ""
echo "=== Running invalidDictionaries ==="
./invalidDictionaries

echo ""
echo "=== Running legacy ==="
./legacy

echo ""
echo "=== Running fullbench (1 iteration) ==="
./fullbench -i1
./fullbench -i1 -P0

echo ""
echo "=== Running fuzzer (short duration: 10s) ==="
./fuzzer -v -T10s

echo ""
echo "=== Running zstreamtest (short duration: 10s) ==="
./zstreamtest -v -T10s
./zstreamtest --newapi -t1 -T10s

echo ""
echo "=== Running decodecorpus ==="
./decodecorpus -t -T1

echo ""
echo "=== Running playTests.sh (main CLI tests) ==="
EXE_PREFIX="" ZSTD_BIN=../programs/zstd DATAGEN_BIN=./datagen ./playTests.sh

echo ""
echo "All tests passed!"
exit 0
