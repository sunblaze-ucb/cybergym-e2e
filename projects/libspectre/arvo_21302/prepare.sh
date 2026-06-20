#!/usr/bin/env bash

# Install build dependencies needed for libspectre
apt-get update -qq
apt-get install -y -qq automake autoconf libtool pkg-config
