#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Install build dependencies required by autogen.sh / compile
apt-get update -qq
apt-get install -y -qq pkg-config autoconf automake libtool > /dev/null 2>&1 || true

# Fix build.sh: the vulnerable code triggers -Wunused-but-set-variable which
# is promoted to error. Add -Wno-error to suppress all warnings-as-errors.
if [ -f /src/build.sh ]; then
  sed -i '1a export CFLAGS="$CFLAGS -Wno-error"\nexport CXXFLAGS="$CXXFLAGS -Wno-error"' /src/build.sh
fi
