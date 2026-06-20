#!/usr/bin/env bash

# Install build dependencies needed by build.sh
apt-get update -qq
apt-get install -y -qq \
  autoconf automake libtool \
  libexpat-dev libsqlite3-dev libwebp-dev libxerces-c-dev \
  libgif-dev libpng-dev liblzma-dev zlib1g-dev \
  libhdf5-serial-dev libaec-dev libicu-dev \
  libcurl4-openssl-dev libjpeg-dev \
  libproj-dev cmake gcc g++

# build.sh links against -lpng12 but image has libpng16
# Create compatibility symlinks
ln -sf /usr/lib/x86_64-linux-gnu/libpng16.a /usr/lib/x86_64-linux-gnu/libpng12.a
ln -sf /usr/lib/x86_64-linux-gnu/libpng16.so /usr/lib/x86_64-linux-gnu/libpng12.so
