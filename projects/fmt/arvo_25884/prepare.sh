#!/usr/bin/env bash

# Install ninja-build which is required by the build.sh (uses -GNinja)
apt-get update -qq
apt-get install -y -qq ninja-build 2>/dev/null || true
