#!/usr/bin/env bash
# Nothing to do!

# --- prefetch so compile.sh/test.sh need no network in the agent phase ---
apt-get update
# apt deletes a .deb from the cache right after installing it
# (APT::Keep-Downloaded-Packages defaults to false), which breaks a SECOND
# --no-download install in the same script. Keep them.
echo 'APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/99keep-debs
apt-get install -y --download-only libgif-dev libpng-dev zlib1g-dev
# Stage the .debs outside apt's cache: apt removes them as it installs, so a
# second --no-download install in the same script would find an empty cache.
mkdir -p /deps/debs
cp -f /var/cache/apt/archives/*.deb /deps/debs/ 2>/dev/null || true

# --- prefetch libjxl third_party tarballs so test.sh needs no network ---
# test.sh runs `bash deps.sh`, which curls ~9 tarballs from github/googlesource.
# deps.sh takes the git-submodule path when its directory is a git repo, so move
# .git aside to force the tarball path, which caches into libjxl/downloads/.
# test.sh's own deps.sh call then finds every tarball present and returns early.
if [ -f "$SRC/libjxl/deps.sh" ]; then
  if [ -d "$SRC/libjxl/.git" ]; then
    mv "$SRC/libjxl/.git" /deps/libjxl_dot_git
    ( cd "$SRC/libjxl" && bash deps.sh ) || echo "WARN: libjxl deps.sh prefetch incomplete"
    mv /deps/libjxl_dot_git "$SRC/libjxl/.git"
  else
    ( cd "$SRC/libjxl" && bash deps.sh ) || echo "WARN: libjxl deps.sh prefetch incomplete"
  fi
fi
