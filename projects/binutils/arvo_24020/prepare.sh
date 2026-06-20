#!/usr/bin/env bash

# Install build and test dependencies needed by binutils-gdb
apt-get update -qq > /dev/null 2>&1
apt-get install -y -qq flex bison texinfo dejagnu > /dev/null 2>&1
