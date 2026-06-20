#!/usr/bin/env bash

# Prepare.sh for libexif (arvo_37211)
# Install autotools needed by build.sh (autoreconf -fiv)
apt-get update -qq
apt-get install -y -qq autoconf automake libtool gettext autopoint pkg-config
