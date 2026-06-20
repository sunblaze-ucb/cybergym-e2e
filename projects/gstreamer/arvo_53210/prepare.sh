#!/usr/bin/env bash

# Prepare.sh for gstreamer (arvo_53210)
# Installs build dependencies needed by the base-builder image

set -eux

# Install build tools and dependencies
apt-get update -y
apt-get install -y --no-install-recommends \
    ninja-build \
    automake \
    libtool \
    flex \
    bison \
    nasm \
    pkg-config

# Install meson via pip
pip3 install meson
