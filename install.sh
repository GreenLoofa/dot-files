#!/usr/bin/env bash
# Symlink dotfiles from this repo into $HOME.
# Existing files are moved to ~/.dotfiles-backup/<timestamp>/ before linking.
#
#   ./install.sh          link configs
#   ./install.sh --brew   install Brewfile packages first, then link
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# repo path -> target path
LINKS=(
  "zsh/.zshrc:$HOME/.zshrc"
  "zsh/.zprofile:$HOME/.zprofile"
  "ghostty/config:$HOME/.config/ghostty/config"
  "starship/starship.toml:$HOME/.config/starship.toml"
  "herdr/config.toml:$HOME/.config/herdr/config.toml"
  "nvim:$HOME/.config/nvim"
  "mise/config.toml:$HOME/.config/mise/config.toml"
  "claude/themes/onenord.json:$HOME/.claude/themes/onenord.json"
)

# Files that shadow our configs and should be moved out of the way.
# Ghostty on macOS loads this after ~/.config/ghostty/config, so it would win.
SHADOWED=(
  "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
)

backup() {
  local target="$1"
  local rel="${target#"$HOME"/}"
  mkdir -p "$BACKUP/$(dirname "$rel")"
  mv "$target" "$BACKUP/$rel"
  echo "  backed up $target"
}

if [[ "${1:-}" == "--brew" ]]; then
  command -v brew >/dev/null || [[ -x /opt/homebrew/bin/brew ]] || {
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  }
  # Fresh Apple Silicon installs aren't on PATH yet (/opt/homebrew/bin)
  for prefix in /opt/homebrew /usr/local; do
    [[ -x $prefix/bin/brew ]] && { eval "$($prefix/bin/brew shellenv)"; break; }
  done
  brew bundle --file="$DOTFILES/Brewfile" || echo "brew bundle reported errors (often just apps installed outside brew)"
  # mise: official installer (prebuilt; brew builds from source on Intel)
  [[ -x "$HOME/.local/bin/mise" ]] || curl -fsSL https://mise.run | sh

  command -v herdr >/dev/null || [[ -x "$HOME/.local/bin/herdr" ]] || curl -fsSL https://herdr.dev/install.sh | sh

  # tree-sitter CLI (needed by nvim-treesitter). Prebuilt binary: brew builds it from source on Intel.
  if [[ ! -x "$HOME/.local/bin/tree-sitter" ]]; then
    arch="$([[ "$(uname -m)" == "arm64" ]] && echo arm64 || echo x64)"
    mkdir -p "$HOME/.local/bin"
    curl -fsSL "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-macos-$arch.gz" |
      gunzip > "$HOME/.local/bin/tree-sitter"
    chmod +x "$HOME/.local/bin/tree-sitter"
  fi
fi

for path in "${SHADOWED[@]}"; do
  [[ -e "$path" ]] && backup "$path"
done

for entry in "${LINKS[@]}"; do
  src="$DOTFILES/${entry%%:*}"
  target="${entry#*:}"

  if [[ -L "$target" && "$(readlink "$target")" == "$src" ]]; then
    echo "ok      $target"
    continue
  fi
  if [[ -e "$target" || -L "$target" ]]; then
    backup "$target"
  fi
  mkdir -p "$(dirname "$target")"
  ln -s "$src" "$target"
  echo "linked  $target -> $src"
done

# Use the repo's tracked git hooks (gitleaks secret scan on commit)
git -C "$DOTFILES" config core.hooksPath .githooks
echo "hooks   core.hooksPath -> .githooks"

# Install global tool versions from mise/config.toml
[[ -x "$HOME/.local/bin/mise" ]] && "$HOME/.local/bin/mise" install --yes

[[ -d "$BACKUP" ]] && echo "Backups saved in $BACKUP"
echo "Done. Open a new terminal to pick up changes."
