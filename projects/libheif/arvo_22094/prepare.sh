#!/usr/bin/env bash

# Install autotools required by libde265's autogen.sh (called by build.sh)
apt-get update -qq && apt-get install -y -qq autoconf automake libtool pkg-config
