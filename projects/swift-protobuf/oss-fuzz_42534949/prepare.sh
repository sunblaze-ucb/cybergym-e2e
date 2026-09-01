#!/usr/bin/env bash

# Reusing CyberGym Image

# --- prefetch git deps ---
mkdir -p /deps/git
mkdir -p $(dirname /deps/git/github.com/apple/swift-docc-plugin)
( git clone --mirror https://github.com/apple/swift-docc-plugin.git /deps/git/github.com/apple/swift-docc-plugin 2>/dev/null || git clone --mirror https://github.com/apple/swift-docc-plugin /deps/git/github.com/apple/swift-docc-plugin ) || echo 'WARN: mirror failed https://github.com/apple/swift-docc-plugin'
[ -d /deps/git/github.com/apple/swift-docc-plugin ] && ln -sfn /deps/git/github.com/apple/swift-docc-plugin /deps/git/github.com/apple/swift-docc-plugin.git || true
mkdir -p $(dirname /deps/git/github.com/apple/swift-protobuf)
( git clone --mirror https://github.com/apple/swift-protobuf.git /deps/git/github.com/apple/swift-protobuf 2>/dev/null || git clone --mirror https://github.com/apple/swift-protobuf /deps/git/github.com/apple/swift-protobuf ) || echo 'WARN: mirror failed https://github.com/apple/swift-protobuf'
[ -d /deps/git/github.com/apple/swift-protobuf ] && ln -sfn /deps/git/github.com/apple/swift-protobuf /deps/git/github.com/apple/swift-protobuf.git || true
# swift-docc-plugin pulls swift-docc-symbolkit transitively. The insteadOf
# rewrite below is host-wide, so any github repo SwiftPM resolves must be
# mirrored here or the clone fails -- with or without network.
for R in swiftlang/swift-docc-symbolkit apple/swift-docc-symbolkit; do
  D=/deps/git/github.com/$R
  mkdir -p "$(dirname "$D")"
  [ -d "$D" ] || git clone --mirror "https://github.com/$R.git" "$D" 2>/dev/null \
    || echo "WARN: mirror failed $R"
  [ -d "$D" ] && ln -sfn "$D" "$D.git" || true
done
git config --global --replace-all url."file:///deps/git/github.com/".insteadOf "https://github.com/"
git config --global protocol.file.allow always
