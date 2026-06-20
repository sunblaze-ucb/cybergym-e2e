#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Install autotools and ragel required by harfbuzz's autogen.sh (called by build.sh)
apt-get update -qq && apt-get install -y -qq autoconf automake libtool pkg-config ragel
