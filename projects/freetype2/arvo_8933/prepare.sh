#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Install autotools required by freetype2's autogen.sh/build.sh
apt-get update -qq && apt-get install -qq -y autoconf automake libtool libarchive-dev
