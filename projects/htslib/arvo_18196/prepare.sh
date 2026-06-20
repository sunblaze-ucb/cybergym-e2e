#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Install autoconf (required by build.sh to generate configure script from configure.ac)
apt-get update -qq && apt-get install -y -qq autoconf zlib1g-dev libbz2-dev liblzma-dev libcurl4-openssl-dev libssl-dev perl
