#!/usr/bin/env bash
# Removes the symlinks and desktop entry created by install.sh.
# Plugin data (~/.local/share/nvim) and any *.bak-* backups are left untouched.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
BIN="$HOME/.local/bin/cide"
DESKTOP="${XDG_DATA_HOME:-$HOME/.local/share}/applications/cide.desktop"

unlink_if_ours() {
  local dst="$1"
  if [[ -L "$dst" && "$(readlink -f "$dst")" == "$ROOT"/* ]]; then
    rm "$dst" && echo "Removed $dst"
  fi
}

unlink_if_ours "$NVIM_DIR"
unlink_if_ours "$BIN"
[[ -f "$DESKTOP" ]] && rm "$DESKTOP" && echo "Removed $DESKTOP"

echo "Done. To also delete downloaded plugins: rm -rf ~/.local/share/nvim/lazy"
