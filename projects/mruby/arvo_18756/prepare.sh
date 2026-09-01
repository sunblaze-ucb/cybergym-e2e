#!/usr/bin/env bash

# Install dependencies
apt-get update && apt-get install -y build-essential ruby bison ninja-build cmake zlib1g-dev libbz2-dev liblzma-dev

# Modern versions of libprotobuf-mutator are not compatible with
# this operating system, so we need to pull a version before
# the Abseil dependency gets added to protobufs.
rm -rf libprotobuf-mutator
git clone https://github.com/google/libprotobuf-mutator.git
cd libprotobuf-mutator
git checkout tags/v1.1
cd ../

# Additional setup commands
rm -rf LPM
mkdir LPM;  cd LPM;  cmake $SRC/libprotobuf-mutator -GNinja -DLIB_PROTO_MUTATOR_DOWNLOAD_PROTOBUF=ON -DLIB_PROTO_MUTATOR_TESTING=OFF -DCMAKE_BUILD_TYPE=Release;  ninja;

# --- prefetch git deps (mirror locally, then rewrite https->file; includes protobuf's own
#     submodules, which `git submodule update` pulls after the clone) ---
mkdir -p /deps/git
mkdir -p $(dirname /deps/git/github.com/google/googletest)
( git clone --mirror https://github.com/google/googletest.git /deps/git/github.com/google/googletest 2>/dev/null || git clone --mirror https://github.com/google/googletest /deps/git/github.com/google/googletest ) || echo 'WARN: could not mirror https://github.com/google/googletest'
[ -d /deps/git/github.com/google/googletest ] && ln -sfn /deps/git/github.com/google/googletest /deps/git/github.com/google/googletest.git || true
mkdir -p $(dirname /deps/git/github.com/libexpat/libexpat)
( git clone --mirror https://github.com/libexpat/libexpat.git /deps/git/github.com/libexpat/libexpat 2>/dev/null || git clone --mirror https://github.com/libexpat/libexpat /deps/git/github.com/libexpat/libexpat ) || echo 'WARN: could not mirror https://github.com/libexpat/libexpat'
[ -d /deps/git/github.com/libexpat/libexpat ] && ln -sfn /deps/git/github.com/libexpat/libexpat /deps/git/github.com/libexpat/libexpat.git || true
mkdir -p $(dirname /deps/git/github.com/google/protobuf)
( git clone --mirror https://github.com/google/protobuf.git /deps/git/github.com/google/protobuf 2>/dev/null || git clone --mirror https://github.com/google/protobuf /deps/git/github.com/google/protobuf ) || echo 'WARN: could not mirror https://github.com/google/protobuf'
[ -d /deps/git/github.com/google/protobuf ] && ln -sfn /deps/git/github.com/google/protobuf /deps/git/github.com/google/protobuf.git || true
mkdir -p $(dirname /deps/git/github.com/protocolbuffers/protobuf)
( git clone --mirror https://github.com/protocolbuffers/protobuf.git /deps/git/github.com/protocolbuffers/protobuf 2>/dev/null || git clone --mirror https://github.com/protocolbuffers/protobuf /deps/git/github.com/protocolbuffers/protobuf ) || echo 'WARN: could not mirror https://github.com/protocolbuffers/protobuf'
[ -d /deps/git/github.com/protocolbuffers/protobuf ] && ln -sfn /deps/git/github.com/protocolbuffers/protobuf /deps/git/github.com/protocolbuffers/protobuf.git || true
mkdir -p $(dirname /deps/git/github.com/google/benchmark)
( git clone --mirror https://github.com/google/benchmark.git /deps/git/github.com/google/benchmark 2>/dev/null || git clone --mirror https://github.com/google/benchmark /deps/git/github.com/google/benchmark ) || echo 'WARN: could not mirror https://github.com/google/benchmark'
[ -d /deps/git/github.com/google/benchmark ] && ln -sfn /deps/git/github.com/google/benchmark /deps/git/github.com/google/benchmark.git || true
mkdir -p $(dirname /deps/git/github.com/abseil/abseil-cpp)
( git clone --mirror https://github.com/abseil/abseil-cpp.git /deps/git/github.com/abseil/abseil-cpp 2>/dev/null || git clone --mirror https://github.com/abseil/abseil-cpp /deps/git/github.com/abseil/abseil-cpp ) || echo 'WARN: could not mirror https://github.com/abseil/abseil-cpp'
[ -d /deps/git/github.com/abseil/abseil-cpp ] && ln -sfn /deps/git/github.com/abseil/abseil-cpp /deps/git/github.com/abseil/abseil-cpp.git || true
mkdir -p $(dirname /deps/git/github.com/open-source-parsers/jsoncpp)
( git clone --mirror https://github.com/open-source-parsers/jsoncpp.git /deps/git/github.com/open-source-parsers/jsoncpp 2>/dev/null || git clone --mirror https://github.com/open-source-parsers/jsoncpp /deps/git/github.com/open-source-parsers/jsoncpp ) || echo 'WARN: could not mirror https://github.com/open-source-parsers/jsoncpp'
[ -d /deps/git/github.com/open-source-parsers/jsoncpp ] && ln -sfn /deps/git/github.com/open-source-parsers/jsoncpp /deps/git/github.com/open-source-parsers/jsoncpp.git || true
mkdir -p $(dirname /deps/git/github.com/google/libprotobuf-mutator)
( git clone --mirror https://github.com/google/libprotobuf-mutator.git /deps/git/github.com/google/libprotobuf-mutator 2>/dev/null || git clone --mirror https://github.com/google/libprotobuf-mutator /deps/git/github.com/google/libprotobuf-mutator ) || echo 'WARN: could not mirror https://github.com/google/libprotobuf-mutator'
[ -d /deps/git/github.com/google/libprotobuf-mutator ] && ln -sfn /deps/git/github.com/google/libprotobuf-mutator /deps/git/github.com/google/libprotobuf-mutator.git || true
git config --global --replace-all url."file:///deps/git/github.com/".insteadOf "https://github.com/"
# git >=2.38 blocks the file:// transport for SUBMODULES (CVE-2022-39253);
# our mirrors are local and trusted, so re-enable it.
git config --global protocol.file.allow always
