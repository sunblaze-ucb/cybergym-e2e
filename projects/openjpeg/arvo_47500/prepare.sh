#!/usr/bin/env bash
set -euo pipefail

# Install libtiff for compare_images test utility
apt-get update && apt-get install -y libtiff-dev libpng-dev

# Note: openjpeg-data is cloned by build.sh into 'data' directory
