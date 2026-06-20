#!/usr/bin/env bash
set -euo pipefail

# Install libtiff for compare_images test utility
apt-get update && apt-get install -y libtiff-dev libpng-dev

# Clone openjpeg test data repository for full test suite
cd $SRC
if [ ! -d "openjpeg-data" ]; then
    git clone https://github.com/uclouvain/openjpeg-data.git --depth 1
fi
