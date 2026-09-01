#!/bin/bash
# test.sh - Unit tests for DuckDB
#
# This script runs ALL ossfuzz regression test cases for the DuckDB parse_fuzz_test target.
# These are the appropriate tests for this OSS-Fuzz Docker image.
#
# Test infrastructure:
#   - Fuzz target: /out/parse_fuzz_test
#   - Test cases: /src/duckdb/test/ossfuzz/cases/ (52 files)
#
# Test counts:
#   Total test cases: 52
#   Runnable (size < 100KB): 46
#   Skipped (size >= 100KB): 6 (to avoid timeout issues)
#
# Skipped test cases (due to large file size):
#   - clusterfuzz-testcase-minimized-parse_fuzz_test-5124469425831936 (523KB)
#   - clusterfuzz-testcase-minimized-parse_fuzz_test-5388785597153280 (197KB)
#   - clusterfuzz-testcase-minimized-parse_fuzz_test-5530663499988992 (307KB)
#   - clusterfuzz-testcase-minimized-parse_fuzz_test-5626923152703488 (231KB)
#   - clusterfuzz-testcase-minimized-parse_fuzz_test-6147478969253888 (265KB)
#   - clusterfuzz-testcase-minimized-parse_fuzz_test-6662101589426176 (492KB)
#
# Skipped test cases (require network):
#   - clusterfuzz-testcase-minimized-parse_fuzz_test-5685636882890752  (install'')
#   - clusterfuzz-testcase-minimized-parse_fuzz_test-6186839351623680  (install'')
#   - clusterfuzz-testcase-minimized-parse_fuzz_test-5455194230226944  (install'.')
#     Each input is an SQL INSTALL statement, so DuckDB tries to fetch an
#     extension from the extension repository. DuckDB's HTTP client does not
#     honour http_proxy, so it attempts a direct connection and fails with no
#     trace in the proxy log.
#     NOTE: the last two do not exist in the unpatched tree -- patch.diff adds
#     them as regression cases alongside its fix, so they only appear in stage 3
#     (tests run WITH the patch applied). A scan of the shipped source will not
#     show them.
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

# Set up sanitizer options (matching the OSS-Fuzz environment)
export ASAN_OPTIONS=alloc_dealloc_mismatch=0:allocator_may_return_null=1:allocator_release_to_os_interval_ms=500:check_malloc_usable_size=0:detect_container_overflow=1:detect_odr_violation=0:detect_leaks=0:detect_stack_use_after_return=1:fast_unwind_on_fatal=0:handle_abort=1:handle_segv=1:handle_sigill=1:max_uar_stack_size_log=16:print_scariness=1:quarantine_size_mb=10:strict_memcmp=1:strip_path_prefix=/workspace/:symbolize=1:use_sigaltstack=1:dedup_token_length=3
export UBSAN_OPTIONS=print_stacktrace=1:print_summary=1:silence_unsigned_overflow=1:strip_path_prefix=/workspace/:symbolize=1:dedup_token_length=3

# Configuration
FUZZ_BIN="/out/parse_fuzz_test"
OSSFUZZ_DIR="${SRC:-/src}/duckdb/test/ossfuzz/cases"
MAX_FILE_SIZE=100000  # 100KB - skip larger files to avoid timeouts
# Cases that need the network (see header); skipped so the suite is offline-clean.
NETWORK_CASES="clusterfuzz-testcase-minimized-parse_fuzz_test-5685636882890752
clusterfuzz-testcase-minimized-parse_fuzz_test-6186839351623680
clusterfuzz-testcase-minimized-parse_fuzz_test-5455194230226944"
TIMEOUT_SECS=120

echo "=== Running DuckDB ossfuzz regression tests ==="
echo "Fuzz binary: $FUZZ_BIN"
echo "Test cases directory: $OSSFUZZ_DIR"
echo ""

# Verify fuzz binary exists
if [ ! -x "$FUZZ_BIN" ]; then
    echo "ERROR: Fuzz binary not found at $FUZZ_BIN"
    exit 1
fi

# Verify test cases directory exists
if [ ! -d "$OSSFUZZ_DIR" ]; then
    echo "ERROR: Test cases directory not found at $OSSFUZZ_DIR"
    exit 1
fi

PASSED=0
FAILED=0
SKIPPED=0
SKIPPED_NET=0
TOTAL=0
FAILED_TESTS=""

# Run all test cases
echo "--- Running all ossfuzz test cases ---"
for test_file in "$OSSFUZZ_DIR"/*; do
    if [ -f "$test_file" ]; then
        test_name=$(basename "$test_file")
        TOTAL=$((TOTAL + 1))

        # Check file size - skip very large files
        file_size=$(stat -c%s "$test_file" 2>/dev/null || echo 0)
        if [ "$file_size" -gt "$MAX_FILE_SIZE" ]; then
            echo "[SKIP] $test_name (file too large: ${file_size} bytes)"
            SKIPPED=$((SKIPPED + 1))
            TOTAL=$((TOTAL - 1))
            continue
        fi

        # Skip cases that require network access. $NETWORK_CASES is unquoted
        # on purpose: word-splitting on any whitespace lets the list span lines.
        skip_net=0
        for nc in $NETWORK_CASES; do
            [ "$nc" = "$test_name" ] && skip_net=1 && break
        done
        if [ "$skip_net" -eq 1 ]; then
            echo "[SKIP] $test_name (requires network)"
            SKIPPED_NET=$((SKIPPED_NET + 1))
            TOTAL=$((TOTAL - 1))
            continue
        fi

        # Run the test
        if timeout $TIMEOUT_SECS "$FUZZ_BIN" "$test_file" >/dev/null 2>&1; then
            PASSED=$((PASSED + 1))
            echo "[PASS] $test_name"
        else
            FAILED=$((FAILED + 1))
            FAILED_TESTS="$FAILED_TESTS\n  - $test_name"
            echo "[FAIL] $test_name"
        fi
    fi
done

echo ""
echo "=== Test Summary ==="
echo "Total runnable tests: $TOTAL"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Skipped (large files): $SKIPPED"
echo "Skipped (requires network): $SKIPPED_NET"

if [ $FAILED -eq 0 ]; then
    echo ""
    echo "All tests passed!"
    exit 0
else
    echo ""
    echo "Failed tests:$FAILED_TESTS"
    exit 1
fi
