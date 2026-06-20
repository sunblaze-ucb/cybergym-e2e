#!/bin/bash
# test.sh - Unit tests for selinux (arvo_36611)
#
# This script runs all available tests for the selinux project.
# The primary test mechanism uses the secilc-fuzzer binary to validate
# CIL policy files from the test directories.
#
# Test coverage:
#   - secilc/test/*.cil: 12 CIL policy test files
#   - libsepol/cil/test/integration_testing/*.cil: 8 integration test files
#
# Total tests: 20 CIL policy files
# Excluded tests: 0
#
# Notes on unavailable tests:
#   - libsepol/tests: Requires CUnit library (not installed in container)
#   - libsepol/cil/test/unit: Unit tests are API-incompatible with current version
#   - libsemanage/tests: Requires CUnit library (not installed in container)
#   - python/sepolgen/tests: Requires selinux python module (not installed)
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

# Counter for tests
PASSED=0
FAILED=0

# Function to run a test file through the fuzzer
run_test() {
    local file="$1"
    local name=$(basename "$file")

    # Run fuzzer with the CIL file - it should process without crashing
    # The fuzzer returns 0 if it successfully processes the input
    if timeout 30 /out/secilc-fuzzer "$file" >/dev/null 2>&1; then
        echo "PASS: $name"
        PASSED=$((PASSED + 1))
    else
        echo "FAIL: $name"
        FAILED=$((FAILED + 1))
    fi
}

echo "Running SELinux CIL policy tests..."
echo "====================================="
echo ""

# Test 1: secilc test files
echo "Testing secilc/test/*.cil files:"
echo "---------------------------------"
for f in /src/selinux/secilc/test/*.cil; do
    if [ -f "$f" ]; then
        run_test "$f"
    fi
done
echo ""

# Test 2: Integration test files
echo "Testing libsepol/cil/test/integration_testing/*.cil files:"
echo "----------------------------------------------------------"
for f in /src/selinux/libsepol/cil/test/integration_testing/*.cil; do
    if [ -f "$f" ]; then
        run_test "$f"
    fi
done
echo ""

# Summary
echo "====================================="
echo "Test Summary:"
echo "  Passed: $PASSED"
echo "  Failed: $FAILED"
echo "  Total:  $((PASSED + FAILED))"
echo "====================================="

if [ $FAILED -gt 0 ]; then
    echo "FAILURE: $FAILED test(s) failed"
    exit 1
fi

echo "All tests passed!"
exit 0
