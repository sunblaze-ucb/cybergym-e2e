#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Create IGRAPH_VERSION file needed by the build system.
# The source tarball lacks git history, so cmake cannot auto-detect the version.
echo "0.10.10" > /src/igraph/IGRAPH_VERSION

# Install flex and bison needed to build igraph's parser sources
apt-get update -qq && apt-get install -y -qq flex bison > /dev/null 2>&1

# --- prefetch tarball deps: upstream build wgets these at compile time, so
#     fetch them in the install phase and make the wget a no-op when present ---
apt-get install -y -qq wget
for BS in $(find "$SRC" -maxdepth 4 -name build.sh 2>/dev/null); do
  for U in $(grep -oE 'https?://download\.gnome\.org[^ "'"'"')]*' "$BS" 2>/dev/null | sort -u); do
    F=$(basename "$U")
    ( cd "$SRC" && { [ -f "$F" ] || wget -q "$U"; } ) || echo "WARN: could not prefetch $U"
  done
  sed -i -E 's@^([[:space:]]*)wget (https?://download\.gnome\.org\S*)@\1test -f "$(basename \2)" || wget \2@' "$BS" 2>/dev/null || true
done
