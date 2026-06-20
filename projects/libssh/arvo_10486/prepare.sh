#!/usr/bin/env bash
set -euo pipefail

# Install dependencies for libssh
apt-get update && apt-get install -y \
    cmake \
    zlib1g-dev \
    libssl-dev \
    libgcrypt20-dev \
    libkrb5-dev \
    libcmocka-dev
