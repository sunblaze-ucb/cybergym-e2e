#!/usr/bin/env bash
set -euo pipefail

echo "=== Running tests for openexr ==="
LOG_FILE=$(mktemp /tmp/openexr_test_log.XXXXXX)

cd $WORK

cmake $SRC/openexr \
    -D BUILD_SHARED_LIBS=OFF \
    -D BUILD_TESTING=ON \
    -D OPENEXR_INSTALL_EXAMPLES=OFF \
    -D OPENEXR_LIB_SUFFIX=

make -j$(nproc)

ctest --output-on-failure | tee $LOG_FILE

# Check if tests passed
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed"
    exit 1
fi
