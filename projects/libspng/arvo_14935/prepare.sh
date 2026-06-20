#!/usr/bin/env bash
set -euo pipefail

apt-get update
apt-get install -y meson ninja-build libpng-dev pkg-config
