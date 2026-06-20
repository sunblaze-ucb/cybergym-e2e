#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update && apt-get install -y pkg-config libncurses5-dev libssl-dev python3-pip libglib2.0-dev
pip3 install -U meson ninja