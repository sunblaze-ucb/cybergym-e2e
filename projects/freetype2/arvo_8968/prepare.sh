#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Install autotools required by freetype2's autogen.sh (called by build.sh)
apt-get update -qq && apt-get install -y -qq autoconf automake libtool libarchive-dev
