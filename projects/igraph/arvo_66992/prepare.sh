#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Create IGRAPH_VERSION file needed by the build system.
# The source tarball lacks git history, so cmake cannot auto-detect the version.
echo "0.10.10" > /src/igraph/IGRAPH_VERSION

# Install flex and bison needed to build igraph's parser sources
apt-get update -qq && apt-get install -y -qq flex bison > /dev/null 2>&1
