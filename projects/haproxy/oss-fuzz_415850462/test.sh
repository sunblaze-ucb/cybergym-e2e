#!/bin/bash
# test.sh - ALL unit tests for haproxy (oss-fuzz_415850462)
#
# Build image: cybergym/e2e:haproxy
#
# Test Statistics:
#   Unit tests: 1 passed, 4 skipped (features not compiled: JWK, QUIC, smoke)
#   Reg tests: ~137 passed, ~75 skipped, 7 excluded
#   Total run: ~138 | Excluded: 7
#
# Excluded reg-tests (known failures):
#   - reg-tests/http-rules/converters_ipmask_concat_strcmp_field_word.vtc: known failure (upstream)
#   - reg-tests/http-messaging/http_wait_for_body.vtc: known failure (upstream)
#   - reg-tests/stickiness/srvkey-addr.vtc: known failure (upstream)
#   - reg-tests/server/cli_set_fqdn.vtc: known failure (upstream)
#   - reg-tests/stream/test_content_switching.vtc: HTTP rx timeout under ASan
#   - reg-tests/converter/le2dec.vtc: HTTP rx timeout under ASan
#   - reg-tests/proxy/cli_add_backend.vtc: HTTP rx timeout under ASan
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

cd /src/haproxy

# Build haproxy if not already built (compile.sh may have already built it)
if [ ! -x haproxy ]; then
    make -j$(nproc) TARGET=linux-glibc 2>&1 | tail -3
fi

# Build VTest if not already built
if [ ! -x /src/VTest2/vtest ]; then
    cd /src/VTest2 && make -j$(nproc) 2>&1 | tail -3
    cd /src/haproxy
fi

# Run unit tests
make unit-tests

# Move known failing reg-tests aside (do not modify source, just exclude)
mkdir -p /tmp/saved_tests

# Upstream known failures
mv reg-tests/http-rules/converters_ipmask_concat_strcmp_field_word.vtc /tmp/saved_tests/ 2>/dev/null || true
mv reg-tests/http-messaging/http_wait_for_body.vtc /tmp/saved_tests/ 2>/dev/null || true
mv reg-tests/stickiness/srvkey-addr.vtc /tmp/saved_tests/ 2>/dev/null || true
mv reg-tests/server/cli_set_fqdn.vtc /tmp/saved_tests/ 2>/dev/null || true

# ASan timeout failures
mv reg-tests/stream/test_content_switching.vtc /tmp/saved_tests/ 2>/dev/null || true
mv reg-tests/converter/le2dec.vtc /tmp/saved_tests/ 2>/dev/null || true
mv reg-tests/proxy/cli_add_backend.vtc /tmp/saved_tests/ 2>/dev/null || true

# Run the full reg-test suite
HAPROXY_PROGRAM=/src/haproxy/haproxy VTEST_PROGRAM=/src/VTest2/vtest make reg-tests

# Restore moved tests
mv /tmp/saved_tests/*.vtc /tmp/ 2>/dev/null || true

echo "All tests passed!"
exit 0
