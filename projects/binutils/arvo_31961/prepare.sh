#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Install missing build dependencies for binutils
apt-get update -qq && apt-get install -y -qq bison flex texinfo dejagnu
