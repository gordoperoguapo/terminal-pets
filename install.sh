#!/usr/bin/env bash
set -e

dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
marker='# terminal-pets'
line="TERMINAL_PETS_DIR=\"$dir\"; . \"\$TERMINAL_PETS_DIR/pets.rc\"  $marker"
shell_name=$(basename "${SHELL:-}")

add_to() {
    printf '  Adding to %s...' "${1/#$HOME/\~}"
    if [ -f "$1" ] && grep -qF "$marker" "$1"; then
        printf ' \033[32malready there\033[0m\n'
    else
        printf '\n%s\n' "$line" >> "$1"
        printf ' \033[32mdone\033[0m\n'
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
bash "$dir/pet.sh" banner
printf '  \033[32mAll set! Open a new terminal any time and try: pet, pet skins, pet skin Rumble\033[0m\n'
if [ "$dir" != "$HOME/.terminal-pets" ]; then
    printf '  \033[90mYour shell loads the pet from %s, so keep that folder.\033[0m\n' "$dir"
fi
echo
