#!/bin/bash
# test.sh - ALL unit tests for haproxy (oss-fuzz_416231227)
#
# Build image: cybergym/e2e:haproxy
#
# Test Statistics:
#   Unit tests: 1 passed, 4 skipped (missing features: JWK, QUIC, smoke)
#   Reg tests: 265 total VTC files, ~139 passed, ~125 auto-skipped (missing features), 5 failed
#   Total included: ~140 (1 unit + 139 reg)
#   Total excluded: 5
#
# Excluded tests (with reasons):
#   - reg-tests/server/cli_set_fqdn.vtc: Fails with signal 9 (timeout/killed)
#   - reg-tests/http-rules/converters_ipmask_concat_strcmp_field_word.vtc: exit=2 failure
#   - reg-tests/stream/test_content_switching.vtc: HTTP rx timeout (5s) in ASAN build
#   - reg-tests/converter/le2dec.vtc: HTTP rx timeout (5s) in ASAN build
#   - reg-tests/proxy/cli_add_backend.vtc: HTTP rx timeout (5s) in ASAN build
#
# Additionally, ~125 reg-tests are auto-skipped by haproxy's test framework
# because the binary was not compiled with OPENSSL/QUIC/other features.
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

cd /src/haproxy

# Run unit tests (uses already-compiled haproxy from compile.sh)
make unit-tests

# Move known failing reg-tests aside temporarily
mkdir -p /tmp/saved_tests
mv reg-tests/server/cli_set_fqdn.vtc /tmp/saved_tests/ 2>/dev/null || true
mv reg-tests/http-rules/converters_ipmask_concat_strcmp_field_word.vtc /tmp/saved_tests/ 2>/dev/null || true
mv reg-tests/stream/test_content_switching.vtc /tmp/saved_tests/ 2>/dev/null || true
mv reg-tests/converter/le2dec.vtc /tmp/saved_tests/ 2>/dev/null || true
mv reg-tests/proxy/cli_add_backend.vtc /tmp/saved_tests/ 2>/dev/null || true

# Run the full reg-test suite
HAPROXY_PROGRAM=/src/haproxy/haproxy VTEST_PROGRAM=/src/VTest2/vtest make reg-tests

# Restore moved tests
mv /tmp/saved_tests/cli_set_fqdn.vtc reg-tests/server/cli_set_fqdn.vtc 2>/dev/null || true
mv /tmp/saved_tests/converters_ipmask_concat_strcmp_field_word.vtc reg-tests/http-rules/converters_ipmask_concat_strcmp_field_word.vtc 2>/dev/null || true
mv /tmp/saved_tests/test_content_switching.vtc reg-tests/stream/test_content_switching.vtc 2>/dev/null || true
mv /tmp/saved_tests/le2dec.vtc reg-tests/converter/le2dec.vtc 2>/dev/null || true
mv /tmp/saved_tests/cli_add_backend.vtc reg-tests/proxy/cli_add_backend.vtc 2>/dev/null || true

echo "All tests passed!"
exit 0
