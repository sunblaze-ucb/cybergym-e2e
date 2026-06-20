#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Install dependencies required by harfbuzz's autogen.sh and compile step
apt-get update -qq > /dev/null 2>&1
apt-get install -y -qq ragel pkg-config autoconf automake libtool > /dev/null 2>&1
