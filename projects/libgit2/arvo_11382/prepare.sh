#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Install dependencies needed for building libgit2 with tests

apt-get update -qq
apt-get install -y -qq libssl-dev pkg-config 2>&1 | tail -3

# Ensure python3 is available at /usr/bin/python3 (needed by cmake generate step)
if [ ! -f /usr/bin/python3 ] && [ -f /usr/local/bin/python3 ]; then
    ln -sf /usr/local/bin/python3 /usr/bin/python3
fi
if [ ! -f /usr/bin/python ] && [ -f /usr/local/bin/python3 ]; then
    ln -sf /usr/local/bin/python3 /usr/bin/python
fi
