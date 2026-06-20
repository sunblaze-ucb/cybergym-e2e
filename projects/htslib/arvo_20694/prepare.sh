#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Install autoconf which is needed by build.sh but missing from the container
apt-get update && apt-get install -y autoconf zlib1g-dev libbz2-dev liblzma-dev libcurl4-openssl-dev libssl-dev
