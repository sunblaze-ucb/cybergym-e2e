#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Nothing to do!

# --- prefetch so compile.sh/test.sh need no network in the agent phase ---
apt-get update
apt-get install -y bison flex
# apt deletes a .deb from the cache right after installing it
# (APT::Keep-Downloaded-Packages defaults to false), which breaks a SECOND
# --no-download install in the same script. Keep them.
echo 'APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/99keep-debs
apt-get install -y --download-only bison flex libxml2-dev

# --- prefetch tarball deps: the upstream build wgets these at compile time, so
#     fetch them here (install phase) and make the wget a no-op when present ---
apt-get install -y -qq wget
for BS in "$SRC/igraph/fuzzing/build.sh" "$SRC/build.sh"; do
  [ -f "$BS" ] || continue
  for U in $(grep -oE 'https?://download\.gnome\.org[^ "'"'"')]*' "$BS" | sort -u); do
    F=$(basename "$U")
    ( cd "$SRC" && [ -f "$F" ] || wget -q "$U" ) || echo "WARN: could not prefetch $U"
  done
  # guard each wget so an already-downloaded tarball short-circuits it
  sed -i -E 's|^([[:space:]]*)wget (https?://download\.gnome\.org\S*)|\1test -f "$(basename \2)" \|\| wget \2|' "$BS"
done
# Stage the .debs outside apt's cache: apt removes them as it installs, so a
# second --no-download install in the same script would find an empty cache.
mkdir -p /deps/debs
cp -f /var/cache/apt/archives/*.deb /deps/debs/ 2>/dev/null || true
