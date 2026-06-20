#!/usr/bin/env bash
cd ${SRC:-/src}/fribidi
echo "=== Running tests for fribidi ==="
LOG_FILE=$(mktemp /tmp/fribidi_test_log.XXXXXX)

mkdir -p bin
cp /usr/bin/fribidi bin/fribidi

export top_builddir=/src/fribidi
export srcdir=/src/fribidi/test

cd test
./run.tests 2>&1 | tee $LOG_FILE

# Check if tests passed
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed"
    exit 1
fi
