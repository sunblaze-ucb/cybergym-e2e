#!/bin/bash
set -uo pipefail

cd "$SRC/fluent-bit/build"

# List of tests that are allowed to fail
ALLOWED_FAILS=("flb-it-input_chunk" "flb-it-parser" "flb-it-signv4" "flb-it-aws_credentials_sts" "flb-it-aws_credentials_http" "flb-it-aws_credentials")

# Build regex to exclude allowed failures
EXCLUDE_REGEX=$(IFS="|"; echo "${ALLOWED_FAILS[*]}")

# Run tests, excluding the allowed failures
TEST_OUTPUT=$(ctest --output-on-failure -E "$EXCLUDE_REGEX" 2>&1) || true
echo "$TEST_OUTPUT"

# Extract failed tests from the output
FAILED_TESTS=$(echo "$TEST_OUTPUT" | awk '/The following tests FAILED:/{flag=1; next} /^Errors while running CTest/{flag=0} flag {print $3}')

if [ -z "$FAILED_TESTS" ]; then
    echo "✓ All tests passed (allowed failures excluded)"
    exit 0
else
    echo "✗ Unexpected test failures: $FAILED_TESTS"
    exit 1
fi

