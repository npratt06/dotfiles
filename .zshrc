# ── Completion system ────────────────────────────────────────────────────────
# Must come before plugins. Scans $fpath for completion definitions
# (_git, _docker, etc.) and registers them so Tab-completion works.
autoload -Uz compinit && compinit

# ── asdf ─────────────────────────────────────────────────────────────────────
# Prepend asdf shims to PATH so managed language versions take precedence
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# ── Starship ──────────────────────────────────────────────────────────────────
# Initialise the starship prompt (reads ~/.config/starship.toml)
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# ── zoxide ───────────────────────────────────────────────────────────────────
# Replaces cd with a frecency-aware jump command (z, zi)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# ── Brew prefix (cached) ──────────────────────────────────────────────────────
# Calling `brew --prefix` is a subprocess — cache it once to avoid
# paying that cost twice when sourcing the plugins below
if command -v brew >/dev/null 2>&1; then
  BREW_PREFIX=$(brew --prefix)
else
  BREW_PREFIX=""
fi

# ── zsh-autosuggestions ───────────────────────────────────────────────────────
# Shows a faded inline suggestion as you type, sourced from command history.
# Accept the suggestion with → (right arrow) or End
if [[ -n "$BREW_PREFIX" && -r "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# ── tmux auto-start ───────────────────────────────────────────────────────────
# On terminal open, attach to (or create) the main tmux session.
# Skipped when already inside tmux or connecting over SSH.
if [ -z "$TMUX" ] && [ -z "$SSH_TTY" ]; then
  TMUX_AUTOSTART="$HOME/scripts/tmux-autostart.sh"
  if [[ -x "$TMUX_AUTOSTART" ]]; then
    "$TMUX_AUTOSTART"
  fi
fi

# ── zsh-syntax-highlighting ───────────────────────────────────────────────────
# Colorises commands as you type — valid commands go green, unknown go red.
# Must be sourced last: it wraps zle widgets and breaks plugins loaded after it.
if [[ -n "$BREW_PREFIX" && -r "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
