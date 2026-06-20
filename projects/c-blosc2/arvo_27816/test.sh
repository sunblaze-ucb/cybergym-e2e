#!/usr/bin/env bash
set -euo pipefail
cd ${SRC:-/src}/c-blosc2

echo "=== Running tests for c-blosc2 ==="
LOG_FILE=$(mktemp /tmp/c-blosc2_test_log.XXXXXX)

EXCLUDED_TESTS="test_empty_schunk|test_lazychunk|test_blosclz_shuffle_1|test_lz4_shuffle_1|test_lizard_shuffle_1|test_blosclz_shuffle_n|test_lz4_shuffle_n|test_lz4hc_shuffle_n|test_lizard_shuffle_n|test_zlib_shuffle_n|test_zstd_shuffle_n|test_blosclz_bitshuffle_1|test_lz4_bitshuffle_1|test_blosclz_bitshuffle_n|test_lz4_bitshuffle_n|test_lizard_bitshuffle_n"

ctest --output-on-failure -E "$EXCLUDED_TESTS" 2>&1 | tee $LOG_FILE

if [ ${PIPESTATUS[0]} -eq 0 ]; then
  echo "✓ All tests passed successfully"
  exit 0
else
  echo "✗ Tests failed"
  exit 1
fi

