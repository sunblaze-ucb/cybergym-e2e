#!/usr/bin/env bash

# Install autotools and other build dependencies needed for flac
apt-get update -y
apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    libtool \
    libtool-bin \
    gettext \
    pkg-config
