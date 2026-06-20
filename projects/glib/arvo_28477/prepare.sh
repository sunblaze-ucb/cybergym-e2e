#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Install meson and ninja (required by glib's build system)
pip3 install 'meson>=0.49.2,<1.0.0' > /dev/null 2>&1
apt-get update -qq > /dev/null 2>&1
apt-get install -y -qq ninja-build pkg-config libmount-dev libselinux1-dev zlib1g-dev libffi-dev gettext libpcre3-dev > /dev/null 2>&1
