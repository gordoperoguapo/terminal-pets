#!/usr/bin/env bash
# terminal-pets one-line installer for bash and zsh
# curl -fsSL https://raw.githubusercontent.com/gordoperoguapo/terminal-pets/main/web-install.sh | bash
set -e

dest="${TERMINAL_PETS_HOME:-$HOME/.terminal-pets}"

printf '\n  \033[36mterminal-pets\033[0m\n\n'
printf '  Downloading...'
mkdir -p "$dest"
if curl -fsSL https://github.com/gordoperoguapo/terminal-pets/archive/refs/heads/main.tar.gz | tar -xz -C "$dest" --strip-components=1; then
    printf ' \033[32mdone\033[0m\n'
else
    printf ' \033[31mfailed\033[0m\n'
    exit 1
fi

bash "$dest/install.sh"
