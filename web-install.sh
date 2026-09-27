#!/usr/bin/env bash
# terminal-pets one-line installer for bash and zsh
# curl -fsSL https://raw.githubusercontent.com/gordoperoguapo/terminal-pets/main/web-install.sh | bash
set -e

dest="${TERMINAL_PETS_HOME:-$HOME/.terminal-pets}"

echo "Downloading terminal-pets..."
mkdir -p "$dest"
curl -fsSL https://github.com/gordoperoguapo/terminal-pets/archive/refs/heads/main.tar.gz | tar -xz -C "$dest" --strip-components=1
echo "Installed to $dest"

bash "$dest/install.sh"
