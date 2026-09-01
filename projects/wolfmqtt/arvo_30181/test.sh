#!/usr/bin/env bash
set -euo pipefail

cd ${SRC:-/src}/wolfmqtt

echo "=== Running tests for wolfmqtt ==="

echo "Building wolfmqtt with examples..."
./autogen.sh
./configure --enable-static --disable-tls
make -j$(nproc)

# --- point the suite at a local broker instead of the public ones ---
# The .test scripts connect to test.mosquitto.org and the hardcoded AWS/Azure
# IoT endpoints, with no skip path when they are unreachable. Serve them all
# from a local mosquitto. Plain MQTT suffices because configure ran
# --disable-tls above. Broker packages are pre-downloaded in prepare.sh.
cp -n /deps/debs/*.deb /var/cache/apt/archives/ 2>/dev/null || true
apt-get install -y --no-download mosquitto
printf 'listener 1883 0.0.0.0\nlistener 8883 0.0.0.0\nallow_anonymous true\n' > /tmp/mosquitto.conf
mosquitto -c /tmp/mosquitto.conf -d
for H in test.mosquitto.org wolfMQTT.azure-devices.net a2dujmi05ideo2.iot.us-west-2.amazonaws.com; do
    grep -q "[[:space:]]${H}$" /etc/hosts || echo "127.0.0.1 ${H}" >> /etc/hosts
done
sleep 1

# Run make check, excluding wiot.test which requires Watson IoT cloud connectivity
echo "Running make check..."
make check TESTS="scripts/client.test scripts/nbclient.test scripts/firmware.test scripts/awsiot.test scripts/azureiothub.test"

echo "✓ All tests passed successfully"
