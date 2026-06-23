# ── Completion system ────────────────────────────────────────────────────────
# Must come before plugins. Scans $fpath for completion definitions
# (_git, _docker, etc.) and registers them so Tab-completion works.
autoload -Uz compinit && compinit

# ── asdf ─────────────────────────────────────────────────────────────────────
# Prepend asdf shims to PATH so managed language versions take precedence
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# ── Starship ──────────────────────────────────────────────────────────────────
# Initialise the starship prompt (reads ~/.config/starship.toml)
eval "$(starship init zsh)"

# ── zoxide ───────────────────────────────────────────────────────────────────
# Replaces cd with a frecency-aware jump command (z, zi)
eval "$(zoxide init zsh)"

# ── Brew prefix (cached) ──────────────────────────────────────────────────────
# Calling `brew --prefix` is a subprocess — cache it once to avoid
# paying that cost twice when sourcing the plugins below
BREW_PREFIX=$(brew --prefix)

# ── zsh-autosuggestions ───────────────────────────────────────────────────────
# Shows a faded inline suggestion as you type, sourced from command history.
# Accept the suggestion with → (right arrow) or End
source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# ── tmux auto-start ───────────────────────────────────────────────────────────
# On terminal open, attach to (or create) the main tmux session.
# Skipped when already inside tmux or connecting over SSH.
if [ -z "$TMUX" ] && [ -z "$SSH_TTY" ]; then
  ~/scripts/tmux-autostart.sh
fi

# ── zsh-syntax-highlighting ───────────────────────────────────────────────────
# Colorises commands as you type — valid commands go green, unknown go red.
# Must be sourced last: it wraps zle widgets and breaks plugins loaded after it.
source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
