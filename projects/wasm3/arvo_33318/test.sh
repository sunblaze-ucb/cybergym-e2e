#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="${SRC:-/src}/wasm3"

echo "=== Running tests for wasm3 ==="
LOG_FILE=$(mktemp /tmp/wasm3_test_log.XXXXXX)
echo "Logging to ${LOG_FILE}"

cd "$PROJECT_ROOT"

echo "=== Configuring and building wasm3 ===" | tee "$LOG_FILE"
cmake . >>"$LOG_FILE" 2>&1
make -j"$(nproc)" >>"$LOG_FILE" 2>&1

# Ensure the location expected by the test scripts exists
mkdir -p build
cp ./wasm3 build/wasm3

cd test

echo "=== Running wasm3 spec tests ===" | tee -a "$LOG_FILE"
set +e
python3 run-spec-test.py 2>&1 | tee -a "$LOG_FILE"
spec_status=${PIPESTATUS[0]}

echo "=== Running wasm3 WASI tests ===" | tee -a "$LOG_FILE"
python3 run-wasi-test.py --exec ../build/wasm3 2>&1 | tee -a "$LOG_FILE"
wasi_status=${PIPESTATUS[0]}
set -e

if [[ "$spec_status" -eq 0 && "$wasi_status" -eq 0 ]]; then
    echo "✓ wasm3 spec + WASI tests passed successfully"
    exit 0
else
    echo "✗ wasm3 tests failed (spec: $spec_status, wasi: $wasi_status)"
    exit 1
fi
