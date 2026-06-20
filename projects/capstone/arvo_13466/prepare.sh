#!/bin/bash

apt-get update && apt-get install -y make cmake python3-pip

pip3 install --upgrade setuptools build wheel pip
