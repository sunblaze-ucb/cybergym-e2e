#!/usr/bin/env bash

cd ${SRC:-/src}/libdwarf

# Build test suites
cmake . -DBUILD_DWARFEXAMPLE=ON -DDO_TESTING=ON
make -j$(nproc)
ctest

# Check if tests passed
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed"
    exit 1
fi

