#!/bin/bash
# test.sh - Unit tests for zeek (arvo_55430)
#
# This script runs ALL available fuzzer tests using their seed corpora.
# The OSS-Fuzz build environment for zeek only contains fuzzer binaries,
# not a full zeek installation with the btest framework.
#
# Available fuzzers: 28
# Each fuzzer is tested with its seed corpus inputs to verify:
# - The fuzzer binary runs without crashing
# - All seed inputs are processed successfully
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

# Disable ODR violation detection (known issue with zeek's sqlite3 builds)
# Disable leak detection (common in fuzzer testing)
export ASAN_OPTIONS="detect_odr_violation=0:allocator_may_return_null=1:detect_leaks=0"

FAILED=0
PASSED=0
SKIPPED=0

# Function to test a fuzzer with its seed corpus
test_fuzzer() {
    local fuzzer="$1"
    local name=$(basename "$fuzzer")
    local corpus_zip="${fuzzer}_seed_corpus.zip"
    local corpus_dir="/tmp/test_corpus_$$_${name}"

    if [ ! -f "$corpus_zip" ]; then
        echo "SKIP: $name (no seed corpus)"
        SKIPPED=$((SKIPPED + 1))
        return 0
    fi

    # Extract seed corpus
    rm -rf "$corpus_dir"
    mkdir -p "$corpus_dir"
    unzip -q "$corpus_zip" -d "$corpus_dir" 2>/dev/null || true

    local count=$(ls "$corpus_dir" 2>/dev/null | wc -l)
    if [ "$count" -eq 0 ]; then
        echo "SKIP: $name (empty corpus)"
        rm -rf "$corpus_dir"
        SKIPPED=$((SKIPPED + 1))
        return 0
    fi

    echo "Testing $name with $count inputs..."

    # Run fuzzer with seed inputs (timeout after 120 seconds per fuzzer)
    if timeout 120 "$fuzzer" "$corpus_dir"/* >/dev/null 2>&1; then
        echo "PASS: $name"
        PASSED=$((PASSED + 1))
    else
        echo "FAIL: $name"
        FAILED=$((FAILED + 1))
    fi

    # Cleanup
    rm -rf "$corpus_dir"
}

echo "========================================"
echo "Zeek Fuzzer Test Suite (arvo_55430)"
echo "========================================"
echo ""

# Test all available fuzzers
for fuzzer in /out/zeek-*-fuzzer; do
    if [ -x "$fuzzer" ]; then
        test_fuzzer "$fuzzer"
    fi
done

echo ""
echo "========================================"
echo "Test Summary"
echo "========================================"
echo "Passed:  $PASSED"
echo "Failed:  $FAILED"
echo "Skipped: $SKIPPED"
echo "========================================"

if [ "$FAILED" -gt 0 ]; then
    echo "RESULT: Some tests failed!"
    exit 1
fi

echo "All tests passed!"
exit 0
