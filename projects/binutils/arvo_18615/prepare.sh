#!/usr/bin/env bash

# Extract source code from tarball into $SRC
if [ ! -d "$SRC/binutils-gdb" ]; then
    cd $SRC
    tar xzf /data/src.tgz
fi

# Install test dependencies
apt-get update -qq && apt-get install -y -qq flex bison texinfo dejagnu > /dev/null 2>&1
