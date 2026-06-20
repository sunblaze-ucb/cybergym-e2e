#!/bin/bash
set -e

# Idea from https://www.linuxfromscratch.org/blfs/view/12.1/multimedia/faad2.html

cd /src/faad2

# Build the project
echo "Installing FAAD2..."
make install -j"$(nproc)"

# Download sample AAC file
echo "Downloading sample..."
curl -L -o sample.aac https://www.nch.com.au/acm/sample.aac

# Run FAAD decoding test
echo "Running decode test..."
faad -o sample.wav sample.aac

echo "✅ Test complete: sample.aac decoded to sample.wav"
