#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Install autotools required by libplist's autogen.sh (called by build.sh)
apt-get update -qq && apt-get install -y -qq autoconf automake libtool pkg-config

# Create .tarball-version since the extracted source does not have .git
echo "2.2.0" > /src/libplist/.tarball-version
