#!/usr/bin/env bash

# Install build and test dependencies
apt-get update -qq && apt-get install -y -qq bison flex file dejagnu > /dev/null 2>&1
