#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Install autotools if not available (base-builder image may not have them)
if ! command -v autoconf &>/dev/null; then
    apt-get update -qq && apt-get install -y -qq autoconf automake libtool pkg-config
fi

# Create .tarball-version file if .git directory is missing
# (src.tgz does not include .git, but autogen.sh/git-version-gen needs it)
if [ ! -d "$SRC/libplist/.git" ]; then
    echo "2.2.0" > "$SRC/libplist/.tarball-version"
fi
