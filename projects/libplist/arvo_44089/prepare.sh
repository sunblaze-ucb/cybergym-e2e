#!/usr/bin/env bash

# Install autotools and build dependencies needed for libplist
apt-get update -qq
apt-get install -y -qq autoconf automake libtool pkg-config
