#!/usr/bin/env bash

# Prepare.sh for leptonica arvo_28181
# Install build tools needed for autotools-based build and testing

apt-get update -qq
apt-get install -y -qq autoconf automake libtool libtool-bin pkg-config 2>/dev/null || true
