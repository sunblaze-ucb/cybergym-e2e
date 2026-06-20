#!/bin/bash
set -uo pipefail

cd "$SRC/irssi"

# Run all tests with Meson and show error logs
if meson test -C build-tests --print-errorlogs; then
    echo "✓ All tests passed"
    exit 0
else
    echo "✗ Some tests failed"
    exit 1
fi
