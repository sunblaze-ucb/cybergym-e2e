#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Install zlib (needed for HDF5 build)
apt-get update -y && apt-get install -y zlib1g-dev
