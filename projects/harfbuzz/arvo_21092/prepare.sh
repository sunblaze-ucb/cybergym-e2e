#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Install build dependencies needed by autogen.sh and compile
apt-get update -qq > /dev/null 2>&1
apt-get install -y -qq pkg-config libtool autotools-dev automake autoconf libglib2.0-dev libfreetype6-dev libcairo2-dev > /dev/null 2>&1
