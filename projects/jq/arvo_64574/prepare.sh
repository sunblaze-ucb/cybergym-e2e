#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Nothing to do!

# --- prefetch so compile.sh/test.sh need no network in the agent phase ---
apt-get update
apt-get install -y autoconf automake bison flex libtool
