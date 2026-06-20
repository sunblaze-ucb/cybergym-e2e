#!/usr/bin/env bash
set -euo pipefail

# Add any additional dependency installation commands here
apt-get update && apt-get install -y zlib1g-dev
