#!/usr/bin/env bash

# Install build dependencies required for libspectre
# Note: We do NOT install libgs-dev here because the project builds
# ghostscript from source (ghostscript-9.50). Installing the system
# libgs-dev would pull in fontconfig and cause linking issues with the
# static gs.a built by ossfuzz.sh.
apt-get update -qq
apt-get install -y -qq autoconf automake libtool pkg-config
