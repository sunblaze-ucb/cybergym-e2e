#!/bin/bash
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/selinux

echo "=== Installing build dependencies ==="
apt-get update -qq
apt-get install -y -qq bison flex 2>/dev/null

echo "=== Rebuilding libsepol with GCC (no sanitizers) ==="
cd /src/selinux/libsepol
make clean >/dev/null 2>&1 || true
CC=gcc CFLAGS='-O2 -Wall -fPIC -Wno-error' make -j4 2>/dev/null

echo "=== Building secilc ==="
cd /src/selinux/secilc
make clean >/dev/null 2>&1 || true
CC=gcc CFLAGS='-O2 -Wall -fPIC -Wno-error' LDFLAGS='-L../libsepol/src' make secilc 2>/dev/null

export LD_LIBRARY_PATH=/src/selinux/libsepol/src

echo "=== Running secilc test with minimum.cil ==="
./secilc test/minimum.cil -o /tmp/minimum.policy -f /dev/null
echo "secilc minimum.cil: PASSED"

echo "=== Running secilc test with anonymous_arg_test.cil ==="
./secilc test/anonymous_arg_test.cil -o /tmp/anonymous_arg.policy -f /dev/null
echo "secilc anonymous_arg_test.cil: PASSED"

echo "=== Running secilc test with deny_rule_test1.cil ==="
./secilc test/deny_rule_test1.cil -o /tmp/deny_rule_test1.policy -f /dev/null
echo "secilc deny_rule_test1.cil: PASSED"

echo "=== Running secilc test with deny_rule_test2.cil ==="
./secilc test/deny_rule_test2.cil -o /tmp/deny_rule_test2.policy -f /dev/null
echo "secilc deny_rule_test2.cil: PASSED"

echo "=== Running secilc test with in_test.cil ==="
./secilc test/in_test.cil -o /tmp/in_test.policy -f /dev/null
echo "secilc in_test.cil: PASSED"

echo "=== Running secilc test with name_resolution_test.cil ==="
./secilc test/name_resolution_test.cil -o /tmp/name_resolution.policy -f /dev/null
echo "secilc name_resolution_test.cil: PASSED"

echo "=== Running secilc test with notself_and_other.cil ==="
./secilc test/notself_and_other.cil -o /tmp/notself_and_other.policy -f /dev/null
echo "secilc notself_and_other.cil: PASSED"

echo "=== Running secilc test with opt-expected.cil ==="
./secilc test/opt-expected.cil -o /tmp/opt-expected.policy -f /dev/null
echo "secilc opt-expected.cil: PASSED"

echo "=== Running secilc test with opt-input.cil ==="
./secilc test/opt-input.cil -o /tmp/opt-input.policy -f /dev/null
echo "secilc opt-input.cil: PASSED"

echo "=== Running libsepol utility tests ==="
cd /src/selinux/libsepol

# Test chkcon utility (check context format)
./utils/chkcon /tmp/minimum.policy "system_u:system_r:kernel_t:s0" && echo "chkcon test: PASSED"

echo ""
echo "=== All tests passed! ==="
exit 0

