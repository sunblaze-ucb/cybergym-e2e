#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Fix autotools timestamps to prevent configure regeneration
# (autoconf is not installed in this container)
cd ${SRC:-/src}/imagemagick
find . -name "*.am" -exec touch {} + 2>/dev/null || true
find . -name "*.in" -exec touch {} + 2>/dev/null || true
sleep 1
find . -name "configure*" -maxdepth 1 -exec touch {} + 2>/dev/null || true
touch version.sh gitversion.sh 2>/dev/null || true
sleep 1
touch configure 2>/dev/null || true
