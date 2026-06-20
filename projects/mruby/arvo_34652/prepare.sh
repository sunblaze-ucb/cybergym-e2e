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

