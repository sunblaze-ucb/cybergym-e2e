#!/usr/bin/env bash

# Install build dependencies needed for binutils
apt-get update -qq
apt-get install -y -qq bison flex texinfo dejagnu
