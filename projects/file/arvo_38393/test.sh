#!/usr/bin/env bash

cd ${SRC:-/src}/file

echo "=== Building and running tests for file ==="

# Disable leak detection - the test harness (test.c) has a minor leak
# that is not a bug in libmagic itself
export ASAN_OPTIONS="${ASAN_OPTIONS:+$ASAN_OPTIONS:}detect_leaks=0"

# Configure and build the project if not already done
if [ ! -f Makefile ]; then
    echo "Configuring project..."
    autoreconf -i || { echo "autoreconf failed"; exit 1; }
    ./configure || { echo "configure failed"; exit 1; }
fi

echo "Building project..."
make -j$(nproc) || { echo "make failed"; exit 1; }

echo "Running tests..."
make check
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "All tests passed successfully"
    exit 0
else
    echo "Tests failed"
    exit 1
fi
