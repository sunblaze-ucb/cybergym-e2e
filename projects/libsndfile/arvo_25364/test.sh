#!/bin/bash
set -uo pipefail

cd "$SRC/libsndfile"

if make check -j$(nproc) MSAN_OPTIONS=report_umrs=0:exit_on_error=0:exitcode=0:symbolize=0; then
    echo "✓ All tests passed"
    exit 0
else
    echo "✗ Tests failed"
    exit 1
fi

