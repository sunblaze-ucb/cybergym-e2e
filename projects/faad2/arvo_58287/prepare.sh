#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
  build-essential \
  pkg-config \
  autoconf \
  automake \
  libtool \
  ca-certificates

# --- prefetch faad2 test sample (test.sh curls it from www.nch.com.au) ---
apt-get install -y -qq curl
mkdir -p /deps/files
[ -f /deps/files/sample.aac ] || curl -sSL -o /deps/files/sample.aac https://www.nch.com.au/acm/sample.aac \
  || echo "WARN: could not prefetch faad2 sample"
