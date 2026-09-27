#!/usr/bin/env bash
set -e

dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
marker='# terminal-pets'
line="TERMINAL_PETS_DIR=\"$dir\"; . \"\$TERMINAL_PETS_DIR/pets.rc\"  $marker"
shell_name=$(basename "${SHELL:-}")

add_to() {
    if [ -f "$1" ] && grep -qF "$marker" "$1"; then
        echo "terminal-pets is already in $1"
    else
        printf '\n%s\n' "$line" >> "$1"
        echo "Added terminal-pets to $1"
    fi
}

chmod +x "$dir/pet.sh"

if [ "$shell_name" = zsh ] || [ -f "$HOME/.zshrc" ]; then
    add_to "$HOME/.zshrc"
fi
if [ "$shell_name" = bash ] || [ -f "$HOME/.bashrc" ]; then
    if [ "$(uname)" = Darwin ]; then
        add_to "$HOME/.bash_profile"
    else
        add_to "$HOME/.bashrc"
    fi
fi

echo
"$dir/pet.sh" banner
echo "Open a new terminal any time to see your pet. Try 'pet' or 'pet skins'."
echo "Keep this folder where it is; your shell loads the pet from here."
