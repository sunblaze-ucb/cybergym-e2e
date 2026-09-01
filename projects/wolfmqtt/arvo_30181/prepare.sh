#!/usr/bin/env bash
set -euo pipefail

apt-get update
apt-get install -y autoconf automake libtool pkg-config

# --- prefetch a local MQTT broker so `make check` needs no internet ---
# Every scripts/*.test connects to a live public broker (test.mosquitto.org and
# the hardcoded AWS/Azure IoT endpoints) and hard-fails when unreachable -- there
# is no skip path. test.sh starts a local mosquitto and maps those hostnames to
# 127.0.0.1. configure runs with --disable-tls, so plain MQTT is enough.
apt-get update
echo 'APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/99keep-debs
apt-get install -y --download-only mosquitto
mkdir -p /deps/debs
cp -f /var/cache/apt/archives/*.deb /deps/debs/ 2>/dev/null || true
