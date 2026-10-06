# --- History ---
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS

# --- Options ---
setopt AUTO_CD INTERACTIVE_COMMENTS

# --- Completion ---
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select

# --- Keybindings ---
bindkey -e                              # emacs-style line editing
bindkey '^[^?' backward-kill-word       # Option+Backspace: delete previous word
WORDCHARS=${WORDCHARS//[\/.-]/}        # stop at / . - so paths delete one segment at a time

# --- Editor ---
export EDITOR=nvim
export VISUAL=nvim
alias vim=nvim

# --- Homebrew (Apple Silicon: /opt/homebrew, Intel: /usr/local) ---
# .zprofile does this for login shells; repeat here for non-login shells.
if [[ -z "$HOMEBREW_PREFIX" ]]; then
  for prefix in /opt/homebrew /usr/local; do
    [[ -x $prefix/bin/brew ]] && { eval "$($prefix/bin/brew shellenv)"; break; }
  done
  unset prefix
fi

# --- PATH ---
typeset -U path   # zsh array tied to $PATH; -U drops duplicates

# Prepend each directory that exists on this machine (last argument ends up first)
path_prepend() {
  local dir
  for dir in "$@"; do [[ -d $dir ]] && path=("$dir" $path); done
}
path_prepend "$HOME/go/bin" "$HOME/.local/bin"

# --- Language toolchains ---
# mise manages node, python, erlang, ... (global: ~/.config/mise/config.toml)
command -v mise >/dev/null && eval "$(mise activate zsh)"
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"   # rust via rustup

# --- Apps ---
[[ -d /Applications/calibre.app ]] && alias ebook-convert='/Applications/calibre.app/Contents/MacOS/ebook-convert'
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# --- Plugins (installed via Brewfile) ---
[[ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] &&
  . "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# --- Per-machine config ---
# Tracked in the repo:  zsh/hosts/<hostname>.zsh   (hostname: `hostname -s`)
# Untracked, private:   ~/.zshrc.local
DOTFILES_ZSH="${${(%):-%x}:A:h}"   # this file's real directory (follows the symlink)
[[ -f "$DOTFILES_ZSH/hosts/$(hostname -s).zsh" ]] && . "$DOTFILES_ZSH/hosts/$(hostname -s).zsh"
[[ -f ~/.zshrc.local ]] && . ~/.zshrc.local

# --- Prompt ---
command -v starship >/dev/null && eval "$(starship init zsh)"

# Must be sourced last
[[ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] &&
  . "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Keep the command word in the normal text color (no red/green while typing)
for style in unknown-token command builtin alias suffix-alias global-alias function \
  hashed-command precommand reserved-word arg0; do
  ZSH_HIGHLIGHT_STYLES[$style]=none
done
unset style
