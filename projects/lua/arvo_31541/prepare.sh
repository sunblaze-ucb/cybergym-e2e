#!/usr/bin/env bash
set -euo pipefail

# Install readline development libraries for Lua interpreter build
apt-get update && apt-get install -y libreadline-dev || \
yum install -y readline-devel || \
apk add --no-cache readline-dev || \
echo "Warning: Could not install readline-dev, tests may fail"
