#!/bin/bash

# adapted from https://github.com/laude-institute/terminal-bench/blob/main/terminal_bench/agents/installed_agents/gemini_cli/gemini-cli-setup.sh.j2

apt-get update
apt-get install -y curl

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash

source "$HOME/.nvm/nvm.sh"

nvm install 22
npm -v

npm install -g @google/gemini-cli@0.37.1

mkdir -p "$HOME/.gemini"
