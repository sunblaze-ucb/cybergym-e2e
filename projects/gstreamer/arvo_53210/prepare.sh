#!/usr/bin/env bash

# Prepare.sh for gstreamer
# Installs build dependencies needed by the base-builder image

set -eux

# Install build tools and dependencies
apt-get update -y
apt-get install -y --no-install-recommends \
    ninja-build \
    automake \
    libtool \
    flex \
    bison \
    nasm \
    pkg-config

# Install meson via pip
pip3 install meson

# --- prefetch gstreamer glib subproject (targeted: only what the build actually needs) ---
# With full network compile.sh takes ~128s and pulls a handful of wraps; a
# blanket `meson subprojects download` pulls all 58 plus nested (3.4GB, >28min)
# and blows the 1800s prepare budget. Fetch glib, then mirror glib's OWN git
# wraps and let meson resolve its two tarball wraps.
python3 -m pip install --quiet --upgrade meson ninja 2>/dev/null || true
GST="$SRC/gstreamer"
mkdir -p /deps/git
mkdir -p $(dirname /deps/git/gitlab.gnome.org/GNOME/gtk-doc)
( git clone --mirror https://gitlab.gnome.org/GNOME/gtk-doc.git /deps/git/gitlab.gnome.org/GNOME/gtk-doc 2>/dev/null || git clone --mirror https://gitlab.gnome.org/GNOME/gtk-doc /deps/git/gitlab.gnome.org/GNOME/gtk-doc ) || echo 'WARN: could not mirror https://gitlab.gnome.org/GNOME/gtk-doc'
[ -d /deps/git/gitlab.gnome.org/GNOME/gtk-doc ] && ln -sfn /deps/git/gitlab.gnome.org/GNOME/gtk-doc /deps/git/gitlab.gnome.org/GNOME/gtk-doc.git || true
mkdir -p $(dirname /deps/git/gitlab.gnome.org/GNOME/gvdb)
( git clone --mirror https://gitlab.gnome.org/GNOME/gvdb.git /deps/git/gitlab.gnome.org/GNOME/gvdb 2>/dev/null || git clone --mirror https://gitlab.gnome.org/GNOME/gvdb /deps/git/gitlab.gnome.org/GNOME/gvdb ) || echo 'WARN: could not mirror https://gitlab.gnome.org/GNOME/gvdb'
[ -d /deps/git/gitlab.gnome.org/GNOME/gvdb ] && ln -sfn /deps/git/gitlab.gnome.org/GNOME/gvdb /deps/git/gitlab.gnome.org/GNOME/gvdb.git || true
mkdir -p $(dirname /deps/git/gitlab.gnome.org/GNOME/sysprof)
( git clone --mirror https://gitlab.gnome.org/GNOME/sysprof.git /deps/git/gitlab.gnome.org/GNOME/sysprof 2>/dev/null || git clone --mirror https://gitlab.gnome.org/GNOME/sysprof /deps/git/gitlab.gnome.org/GNOME/sysprof ) || echo 'WARN: could not mirror https://gitlab.gnome.org/GNOME/sysprof'
[ -d /deps/git/gitlab.gnome.org/GNOME/sysprof ] && ln -sfn /deps/git/gitlab.gnome.org/GNOME/sysprof /deps/git/gitlab.gnome.org/GNOME/sysprof.git || true
mkdir -p $(dirname /deps/git/gitlab.freedesktop.org/gstreamer/meson-ports/libffi)
( git clone --mirror https://gitlab.freedesktop.org/gstreamer/meson-ports/libffi.git /deps/git/gitlab.freedesktop.org/gstreamer/meson-ports/libffi 2>/dev/null || git clone --mirror https://gitlab.freedesktop.org/gstreamer/meson-ports/libffi /deps/git/gitlab.freedesktop.org/gstreamer/meson-ports/libffi ) || echo 'WARN: could not mirror https://gitlab.freedesktop.org/gstreamer/meson-ports/libffi'
[ -d /deps/git/gitlab.freedesktop.org/gstreamer/meson-ports/libffi ] && ln -sfn /deps/git/gitlab.freedesktop.org/gstreamer/meson-ports/libffi /deps/git/gitlab.freedesktop.org/gstreamer/meson-ports/libffi.git || true
mkdir -p $(dirname /deps/git/github.com/frida/proxy-libintl)
( git clone --mirror https://github.com/frida/proxy-libintl.git /deps/git/github.com/frida/proxy-libintl 2>/dev/null || git clone --mirror https://github.com/frida/proxy-libintl /deps/git/github.com/frida/proxy-libintl ) || echo 'WARN: could not mirror https://github.com/frida/proxy-libintl'
[ -d /deps/git/github.com/frida/proxy-libintl ] && ln -sfn /deps/git/github.com/frida/proxy-libintl /deps/git/github.com/frida/proxy-libintl.git || true
git config --global --replace-all url."file:///deps/git/github.com/".insteadOf "https://github.com/"
git config --global --replace-all url."file:///deps/git/gitlab.freedesktop.org/".insteadOf "https://gitlab.freedesktop.org/"
git config --global --replace-all url."file:///deps/git/gitlab.gnome.org/".insteadOf "https://gitlab.gnome.org/"
git config --global protocol.file.allow always
if [ -d "$GST/subprojects" ]; then
  # build.sh passes --force-fallback-for=zlib, so gstreamer's OWN zlib wrap
  # is used as well as glib's; fetch both (plus pcre2) at the top level.
  for W in glib zlib pcre2; do
    ( cd "$GST" && meson subprojects download "$W" ) || echo "WARN: wrap $W download failed"
  done
  for G in "$GST"/subprojects/glib-*; do
    [ -d "$G/subprojects" ] || continue
    ( cd "$G" && meson subprojects download ) || echo "WARN: glib nested wraps failed"
  done
fi

  # meson resolves a subproject's wraps against the TOP-LEVEL packagecache, so
  # lift glib's cached tarballs/patches up to gstreamer's.
  mkdir -p "$GST/subprojects/packagecache"
  for G in "$GST"/subprojects/glib-*; do
    [ -d "$G/subprojects/packagecache" ] || continue
    cp -n "$G"/subprojects/packagecache/* "$GST/subprojects/packagecache/" 2>/dev/null || true
  done
  ls "$GST/subprojects/packagecache" | head
