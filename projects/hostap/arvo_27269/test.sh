#!/bin/bash

cd $SRC/hostap/tests

LOG_FILE=$(mktemp /tmp/hostap_test_log.XXXXXX)

make run-tests | tee $LOG_FILE

# Validate that tests passed
if grep -q "All tests completed successfully" $LOG_FILE; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed or did not complete successfully"
    exit 1
fi
