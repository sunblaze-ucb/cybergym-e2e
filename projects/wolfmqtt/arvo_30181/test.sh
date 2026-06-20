#!/usr/bin/env bash
set -euo pipefail

cd ${SRC:-/src}/wolfmqtt

echo "=== Running tests for wolfmqtt ==="

echo "Building wolfmqtt with examples..."
./autogen.sh
./configure --enable-static --disable-tls
make -j$(nproc)

# Run make check, excluding wiot.test which requires Watson IoT cloud connectivity
echo "Running make check..."
make check TESTS="scripts/client.test scripts/nbclient.test scripts/firmware.test scripts/awsiot.test scripts/azureiothub.test"

echo "✓ All tests passed successfully"
