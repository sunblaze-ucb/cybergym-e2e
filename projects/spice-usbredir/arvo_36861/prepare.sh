#!/usr/bin/env bash
set -euo pipefail

apt-get update
apt-get install -y meson pkg-config libusb-1.0-0-dev libglib2.0-dev
