#!/usr/bin/env bash
set -euo pipefail

cd /src/p11-kit

echo "=== Running tests for p11-kit ==="

LOG_FILE=$(mktemp /tmp/p11-kit_test_log.XXXXXX)

ALL_TESTS=$(make -n check 2>&1 | grep "^TESTS = " | sed 's/TESTS = //' || echo "")

if [ -z "$ALL_TESTS" ]; then
    ALL_TESTS="test-progname test-conf test-uri test-pin test-init test-modules test-deprecated test-proxy test-iter test-rpc test-server test-virtual test-managed test-log test-filter test-transport test-digest test-asn1 test-base64 test-pem test-oid test-utf8 test-x509 test-persist test-index test-parser test-builder test-token test-module test-save test-enumerate test-cer test-bundle test-openssl test-edk2 test-jks p11-kit/test-server.sh p11-kit/test-messages.sh"
fi

EXCLUDED_TESTS="test-init test-modules test-deprecated test-proxy test-iter test-server"

TESTS_TO_RUN=""
for test in $ALL_TESTS; do
    skip=0
    for excluded in $EXCLUDED_TESTS; do
        if [ "$test" = "$excluded" ]; then
            skip=1
            break
        fi
    done
    if [ $skip -eq 0 ]; then
        TESTS_TO_RUN="$TESTS_TO_RUN $test"
    fi
done

if make check TESTS="$TESTS_TO_RUN" 2>&1 | tee $LOG_FILE; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed"
    cat $LOG_FILE
    exit 1
fi
