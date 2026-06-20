#!/usr/bin/env bash
set -euo pipefail

# Install libtool and pkg-config which are required by autogen.sh
# Install check library for running unit tests
apt-get update && apt-get install -y libtool pkg-config check
