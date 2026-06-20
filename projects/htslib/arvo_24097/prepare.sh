#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Install build dependencies required by htslib's build.sh (autoconf, autoheader)
# and the libraries needed for compilation and testing.
apt-get update -qq
apt-get install -y -qq autoconf zlib1g-dev libbz2-dev liblzma-dev libcurl4-openssl-dev
