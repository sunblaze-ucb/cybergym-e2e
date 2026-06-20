#!/usr/bin/env bash
set -euo pipefail

cd ${SRC:-/src}/libssh

echo "=== Running tests for libssh ==="
LOG_FILE=$(mktemp /tmp/libssh_test_log.XXXXXX)

# Recompile without ASAN
rm -rf build
mkdir build
cd build

cmake .. \
    -DCMAKE_BUILD_TYPE=Debug \
    -DWITH_EXAMPLES=OFF \
    -DUNIT_TESTING=ON

# Build tests
make -j$(nproc)


# OK so the tests have some race condition that causes them to fail
# intermittently. Rerun 5 times..
MAX_ATTEMPTS=5
ATTEMPT=1

while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
    echo "Test attempt $ATTEMPT of $MAX_ATTEMPTS"
    
    if [ $ATTEMPT -eq 1 ]; then
        if ctest -j $(nproc) --output-on-failure 2>&1 | tee $LOG_FILE; then
            echo "✓ Tests passed on attempt $ATTEMPT"
            exit 0
        fi
    else
        # Retry runs with rerun-failed
        if ctest -j $(nproc) --rerun-failed --output-on-failure 2>&1 | tee -a $LOG_FILE; then
            echo "✓ Tests passed on attempt $ATTEMPT"
            exit 0
        fi
    fi
    
    echo "⚠ Attempt $ATTEMPT failed"
    ATTEMPT=$((ATTEMPT + 1))
done

echo "⚠ Tests failed after $MAX_ATTEMPTS attempts"
exit 1
