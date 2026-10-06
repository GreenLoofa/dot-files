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

# --- PATH ---
export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"

# --- Language toolchains (only if installed on this machine) ---
[[ -f /usr/local/opt/asdf/libexec/asdf.sh ]] && . /usr/local/opt/asdf/libexec/asdf.sh
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

if [[ -d "$HOME/.pyenv" ]]; then
  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init -)"
  command -v pyenv-virtualenv-init >/dev/null && eval "$(pyenv virtualenv-init -)"
fi

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && . "$NVM_DIR/bash_completion"

# --- Apps ---
[[ -d /Applications/calibre.app ]] && alias ebook-convert='/Applications/calibre.app/Contents/MacOS/ebook-convert'
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# --- Plugins (installed via Brewfile) ---
BREW_PREFIX="${HOMEBREW_PREFIX:-$(brew --prefix 2>/dev/null)}"
[[ -f "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] &&
  . "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# --- Machine-specific overrides (not tracked) ---
[[ -f ~/.zshrc.local ]] && . ~/.zshrc.local

# --- Prompt ---
command -v starship >/dev/null && eval "$(starship init zsh)"

# Must be sourced last
[[ -f "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] &&
  . "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Keep the command word in the normal text color (no red/green while typing)
for style in unknown-token command builtin alias suffix-alias global-alias function \
  hashed-command precommand reserved-word arg0; do
  ZSH_HIGHLIGHT_STYLES[$style]=none
done
unset style
