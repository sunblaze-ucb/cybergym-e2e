#!/usr/bin/env bash
set -euo pipefail

# Add any additional dependency installation commands here
# Dependencies for integration tests since this is a redis client library
apt-get update && apt-get install -y redis-server
redis-server --daemonize yes
