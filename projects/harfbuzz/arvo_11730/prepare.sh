#!/usr/bin/env bash

# Install build dependencies required by compile.sh (autogen.sh needs these)
apt-get update -qq
apt-get install -y -qq autoconf automake libtool libtool-bin pkg-config \
    libglib2.0-dev libfreetype6-dev libicu-dev libcairo2-dev > /dev/null 2>&1
