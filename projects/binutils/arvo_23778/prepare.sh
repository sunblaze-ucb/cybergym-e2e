#!/usr/bin/env bash

# Install missing build dependencies for binutils
apt-get update -qq
apt-get install -y -qq flex bison texinfo dejagnu 2>/dev/null || true
