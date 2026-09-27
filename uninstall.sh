#!/usr/bin/env bash
set -e

marker='# terminal-pets'
removed=0

for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile"; do
    if [ -f "$rc" ] && grep -qF "$marker" "$rc"; then
        tmp=$(mktemp)
        grep -vF "$marker" "$rc" > "$tmp" || true
        cat "$tmp" > "$rc"
        rm -f "$tmp"
        echo "Removed terminal-pets from $rc"
        removed=1
    fi
done

if [ $removed = 1 ]; then
    echo "Open a new terminal to finish. You can now delete this folder."
else
    echo "terminal-pets wasn't in any of your shell startup files."
fi
