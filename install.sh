#!/usr/bin/env bash
# Installs C IDE by symlinking this repo into place, so edits here take effect immediately.
#   ~/.config/nvim            -> <repo>/nvim
#   ~/.local/bin/cide         -> <repo>/bin/cide
#   ~/.local/share/applications/cide.desktop  (generated)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
BIN_DIR="$HOME/.local/bin"
APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*"; }

# 1. Dependencies
missing=()
for cmd in nvim git gcc clangd gdb make rg; do
  command -v "$cmd" >/dev/null || missing+=("$cmd")
done
optional=()
for cmd in foot fd fzf lazygit cmake ninja wl-copy; do
  command -v "$cmd" >/dev/null || optional+=("$cmd")
done
if ((${#missing[@]})); then
  warn "Missing required tools: ${missing[*]}"
  warn "Fedora: sudo dnf install neovim git gcc clang-tools-extra gdb make ripgrep"
  exit 1
fi
((${#optional[@]})) && warn "Optional tools not found: ${optional[*]}"

if command -v nvim >/dev/null; then
  ver="$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+')"
  if [[ "$(printf '%s\n0.11\n' "$ver" | sort -V | head -1)" != "0.11" ]]; then
    warn "Neovim >= 0.11 is required (found $ver)"; exit 1
  fi
fi

# 2. Symlinks (an existing non-symlink target is backed up first)
link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -L "$dst" ]]; then
    rm "$dst"
  elif [[ -e "$dst" ]]; then
    local backup="$dst.bak-$(date +%Y%m%d-%H%M%S)"
    warn "Backing up $dst -> $backup"
    mv "$dst" "$backup"
  fi
  ln -s "$src" "$dst"
  info "Linked $dst -> $src"
}

chmod +x "$ROOT/bin/cide"
link "$ROOT/nvim" "$NVIM_DIR"
link "$ROOT/bin/cide" "$BIN_DIR/cide"

# 3. Desktop entry
mkdir -p "$APP_DIR"
sed "s|@BIN@|$BIN_DIR/cide|" "$ROOT/desktop/cide.desktop.in" > "$APP_DIR/cide.desktop"
command -v update-desktop-database >/dev/null && update-desktop-database "$APP_DIR" 2>/dev/null || true
info "Installed desktop entry: $APP_DIR/cide.desktop"

# 4. Plugins (pinned to the versions in nvim/lazy-lock.json)
info "Installing plugins (this can take a minute)..."
nvim --headless "+Lazy! restore" +qa >/dev/null 2>&1 || warn "Plugin install reported errors; run :Lazy inside Neovim"

info "Done. Run 'cide' in a terminal, 'cide -w <dir>' for a dedicated window, or open 'C IDE' from the app menu."
case ":$PATH:" in *":$BIN_DIR:"*) ;; *) warn "$BIN_DIR is not in your PATH" ;; esac
