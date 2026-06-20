#!/usr/bin/env bash

# Install missing build dependencies
apt-get update -qq
apt-get install -y -qq file bison flex texinfo dejagnu 2>/dev/null
