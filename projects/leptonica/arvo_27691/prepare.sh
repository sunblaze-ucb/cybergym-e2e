#!/usr/bin/env bash

# Install build dependencies needed for leptonica and its dependencies
apt-get update -qq
apt-get install -y --no-install-recommends \
    autoconf automake libtool pkg-config gnuplot-nox
