#!/usr/bin/env bash

# Prepare.sh for binutils (arvo_25841)
# Install dependencies missing from base-builder image

apt-get update -y
apt-get install -y --no-install-recommends \
    bison \
    flex \
    texinfo \
    dejagnu \
    expect \
    tcl \
    zlib1g-dev
