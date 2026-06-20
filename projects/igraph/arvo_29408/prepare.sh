#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Install flex and bison required for igraph's parser generation during cmake
apt-get update -qq && apt-get install -y -qq flex bison

# Comment out use_all_warnings in all CMakeLists.txt files to avoid -Werror
# build failures with clang 22's strict-prototypes and unused-but-set-variable warnings
find /src/igraph -name CMakeLists.txt -exec sed -i 's/^use_all_warnings/\#use_all_warnings/g' {} +
