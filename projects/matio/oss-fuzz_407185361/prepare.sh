#!/usr/bin/env bash
# Nothing to do!

# --- prefetch autoconf tarball (matio's ossfuzz/build.sh wgets it at build
#     time; copy from a local cache instead, falling back to the network) ---
BS="$SRC/matio/ossfuzz/build.sh"
if [ -f "$BS" ]; then
  apt-get install -y -qq wget
  mkdir -p /deps
  ( cd /deps && wget -q http://ftp.gnu.org/gnu/autoconf/autoconf-2.71.tar.gz ) \
    || echo "WARN: could not prefetch autoconf"
  sed -i -E 's#^wget (http://ftp\.gnu\.org/gnu/autoconf/autoconf-2\.71\.tar\.gz)#cp /deps/autoconf-2.71.tar.gz . || wget \1#' "$BS"
fi
