#!/bin/bash

apt-get update
apt-get install -y curl

curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env
uv python install 3.13

VENV="/scripts/.venv"
mkdir -p /scripts
uv venv $VENV --python 3.13

source $VENV/bin/activate

uv pip install tomli
