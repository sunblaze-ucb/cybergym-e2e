#!/bin/bash
set -uo pipefail

cd "$SRC/hunspell"

if make check -j$(nproc); then
    echo "All tests passed"
    exit 0
else
    echo "Tests failed"
    exit 1
fi
