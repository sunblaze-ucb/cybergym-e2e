#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Install required build dependencies for leptonica

set -e

# Update package list
apt-get update -qq

# Install autotools and pkg-config required for leptonica build
apt-get install -y \
    autoconf \
    automake \
    libtool \
    pkg-config
