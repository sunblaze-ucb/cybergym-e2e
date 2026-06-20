#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Install build dependencies needed by compile.sh and test.sh
apt-get update -qq > /dev/null 2>&1
apt-get install -y -qq zlib1g-dev libcurl4-openssl-dev > /dev/null 2>&1
