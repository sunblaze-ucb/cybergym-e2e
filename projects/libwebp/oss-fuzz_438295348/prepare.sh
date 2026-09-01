#!/usr/bin/env bash
# Nothing to do!
# --- prefetch fuzztest deps (git mirrors + the antlr zip FetchContent pulls by URL) ---
apt-get install -y -qq wget unzip
mkdir -p /deps/git
mkdir -p $(dirname /deps/git/github.com/google/fuzztest)
( git clone --mirror https://github.com/google/fuzztest.git /deps/git/github.com/google/fuzztest 2>/dev/null || git clone --mirror https://github.com/google/fuzztest /deps/git/github.com/google/fuzztest ) || echo 'WARN: could not mirror https://github.com/google/fuzztest'
[ -d /deps/git/github.com/google/fuzztest ] && ln -sfn /deps/git/github.com/google/fuzztest /deps/git/github.com/google/fuzztest.git || true
mkdir -p $(dirname /deps/git/github.com/abseil/abseil-cpp)
( git clone --mirror https://github.com/abseil/abseil-cpp.git /deps/git/github.com/abseil/abseil-cpp 2>/dev/null || git clone --mirror https://github.com/abseil/abseil-cpp /deps/git/github.com/abseil/abseil-cpp ) || echo 'WARN: could not mirror https://github.com/abseil/abseil-cpp'
[ -d /deps/git/github.com/abseil/abseil-cpp ] && ln -sfn /deps/git/github.com/abseil/abseil-cpp /deps/git/github.com/abseil/abseil-cpp.git || true
mkdir -p $(dirname /deps/git/github.com/google/re2)
( git clone --mirror https://github.com/google/re2.git /deps/git/github.com/google/re2 2>/dev/null || git clone --mirror https://github.com/google/re2 /deps/git/github.com/google/re2 ) || echo 'WARN: could not mirror https://github.com/google/re2'
[ -d /deps/git/github.com/google/re2 ] && ln -sfn /deps/git/github.com/google/re2 /deps/git/github.com/google/re2.git || true
mkdir -p $(dirname /deps/git/github.com/google/googletest)
( git clone --mirror https://github.com/google/googletest.git /deps/git/github.com/google/googletest 2>/dev/null || git clone --mirror https://github.com/google/googletest /deps/git/github.com/google/googletest ) || echo 'WARN: could not mirror https://github.com/google/googletest'
[ -d /deps/git/github.com/google/googletest ] && ln -sfn /deps/git/github.com/google/googletest /deps/git/github.com/google/googletest.git || true
mkdir -p $(dirname /deps/git/github.com/protocolbuffers/protobuf)
( git clone --mirror https://github.com/protocolbuffers/protobuf.git /deps/git/github.com/protocolbuffers/protobuf 2>/dev/null || git clone --mirror https://github.com/protocolbuffers/protobuf /deps/git/github.com/protocolbuffers/protobuf ) || echo 'WARN: could not mirror https://github.com/protocolbuffers/protobuf'
[ -d /deps/git/github.com/protocolbuffers/protobuf ] && ln -sfn /deps/git/github.com/protocolbuffers/protobuf /deps/git/github.com/protocolbuffers/protobuf.git || true
mkdir -p $(dirname /deps/git/github.com/nlohmann/json)
( git clone --mirror https://github.com/nlohmann/json.git /deps/git/github.com/nlohmann/json 2>/dev/null || git clone --mirror https://github.com/nlohmann/json /deps/git/github.com/nlohmann/json ) || echo 'WARN: could not mirror https://github.com/nlohmann/json'
[ -d /deps/git/github.com/nlohmann/json ] && ln -sfn /deps/git/github.com/nlohmann/json /deps/git/github.com/nlohmann/json.git || true
mkdir -p $(dirname /deps/git/github.com/google/flatbuffers)
( git clone --mirror https://github.com/google/flatbuffers.git /deps/git/github.com/google/flatbuffers 2>/dev/null || git clone --mirror https://github.com/google/flatbuffers /deps/git/github.com/google/flatbuffers ) || echo 'WARN: could not mirror https://github.com/google/flatbuffers'
[ -d /deps/git/github.com/google/flatbuffers ] && ln -sfn /deps/git/github.com/google/flatbuffers /deps/git/github.com/google/flatbuffers.git || true
git config --global --replace-all url."file:///deps/git/github.com/".insteadOf "https://github.com/"
# antlr arrives as a zip from www.antlr.org, so insteadOf cannot rewrite it.
# Read the exact version from the fuzztest commit this task pins, then stage it.
FT=/deps/git/github.com/google/fuzztest
TAG=$(grep -rhoE "GIT_TAG[[:space:]]+[0-9a-f]{40}" "$SRC/libwebp/tests/fuzzer/CMakeLists.txt" 2>/dev/null | head -1 | awk '{print $2}')
AURL=""
if [ -n "$TAG" ] && [ -d "$FT" ]; then
  AURL=$(git -C "$FT" show "$TAG:cmake/BuildDependencies.cmake" 2>/dev/null \
         | grep -oE "https://www\.antlr\.org/download/[^ )]+\.zip" | head -1)
fi
[ -n "$AURL" ] || AURL=https://www.antlr.org/download/antlr4-cpp-runtime-4.12.0-source.zip
if [ ! -f /deps/antlr_cpp/CMakeLists.txt ]; then
  rm -rf /deps/antlr_cpp && mkdir -p /deps/antlr_cpp
  ( cd /tmp && wget -q -O antlr.zip "$AURL" && unzip -q -o antlr.zip -d /deps/antlr_cpp ) \
    || echo "WARN: could not prefetch antlr ($AURL)"
  # the zip may or may not have a single top-level directory
  if [ ! -f /deps/antlr_cpp/CMakeLists.txt ]; then
    D=$(find /deps/antlr_cpp -maxdepth 2 -name CMakeLists.txt | head -1)
    [ -n "$D" ] && cp -a "$(dirname "$D")"/. /deps/antlr_cpp/ || true
  fi
fi

# build.sh hardcodes EXTRA_CMAKE_FLAGS, so an exported value is discarded.
# Inject the FetchContent override straight into its cmake invocation.
for BS in $(find "$SRC/libwebp" -maxdepth 5 -name build.sh 2>/dev/null); do
  sed -i -E 's@^(cmake -S \. -B build -DWEBP_BUILD_FUZZTEST=ON)@\1 -DFETCHCONTENT_SOURCE_DIR_ANTLR_CPP=/deps/antlr_cpp@' "$BS"
done
# git >=2.38 blocks the file:// transport for SUBMODULES (CVE-2022-39253);
# our mirrors are local and trusted, so re-enable it.
git config --global protocol.file.allow always
