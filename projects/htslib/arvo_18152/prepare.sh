#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Install build dependencies required for htslib
apt-get update -qq
apt-get install -y -qq autoconf zlib1g-dev libbz2-dev liblzma-dev libcurl4-openssl-dev libssl-dev
