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

# --- prefetch so compile.sh/test.sh need no network in the agent phase ---
apt-get update
# apt deletes a .deb from the cache right after installing it
# (APT::Keep-Downloaded-Packages defaults to false), which breaks a SECOND
# --no-download install in the same script. Keep them.
echo 'APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/99keep-debs
# libfontconfig1-dev matters: meson.build declares
#   dependency('fontconfig', ..., fallback: ['fontconfig','fontconfig_dep'])
# so without the system package meson git-clones the fontconfig subproject
# from github at configure time. Installing it keeps fontconfig support on
# (same coverage as a networked run) and needs no fetch.
apt-get install -y --download-only libfreetype6-dev libglib2.0-dev libfontconfig1-dev meson ninja-build pkg-config
# Stage the .debs outside apt's cache: apt removes them as it installs, so a
# second --no-download install in the same script would find an empty cache.
mkdir -p /deps/debs
cp -f /var/cache/apt/archives/*.deb /deps/debs/ 2>/dev/null || true
