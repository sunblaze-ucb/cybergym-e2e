#!/usr/bin/env bash

PROJECT_DIR="${SRC:-/src}/mruby"
cd "$PROJECT_DIR"

echo "=== Running tests for mruby ==="

if rake clean && rake test -j $(nproc); then
    TEST_PASSED=true
fi

# Final result
if [ "$TEST_PASSED" = true ]; then
    echo ""
    echo "========================================="
    echo "✓ Tests completed successfully"
    echo "========================================="
    exit 0
else
    echo ""
    echo "========================================="
    echo "⚠ Warning: No suitable test command found or all tests failed"
    echo "You may need to manually configure test.sh for this project"
    echo "========================================="
    exit 1
fi
