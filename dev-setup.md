# Dev Terminal Setup

A guide for setting up or replicating the terminal environment on a new machine.

## What's included

| Tool | Purpose |
|---|---|
| Ghostty | Terminal emulator |
| tmux | Terminal session and window/pane manager |
| Starship | Shell prompt styling |
| JetBrains Mono Nerd Font | Font required for Starship icons/glyphs |
| zoxide | Frecency-based smart `cd` replacement |
| zsh-autosuggestions | Inline history-based suggestions as you type |
| zsh-syntax-highlighting | Real-time command syntax coloring |
| asdf | Multi-language version manager |

---

## Setup steps

### 1. Install Homebrew

If not already installed:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install all packages

Place the `Brewfile` anywhere (e.g. `~/Repos/dotfiles/Brewfile`), then run:

```bash
brew bundle --file ~/Repos/dotfiles/Brewfile
```

Safe to re-run at any time — all installs are idempotent.

### 3. Place dotfiles

Use the installer to preview changes first:

```bash
cd ~/Repos/dotfiles
./scripts/install.sh
```

Use full diff mode when you want the line-by-line details:

```bash
./scripts/install.sh --diff
```

Full diffs are colorized when Git is available.

If Claude Code is not installed on the machine, skip its settings:

```bash
./scripts/install.sh --skip-claude
```

Then apply the changes:

```bash
./scripts/install.sh --apply
```

To apply everything except Claude Code settings:

```bash
./scripts/install.sh --apply --skip-claude
```

The installer backs up existing destination files under `~/.dotfiles-backups/` before replacing them.

If copying manually, use these destinations:

| File | Destination |
|---|---|
| `.zshrc` | `~/.zshrc` |
| `.gitconfig` | aliases merged into `~/.gitconfig` |
| `.vimrc` | `~/.vimrc` |
| `config/starship.toml` | `~/.config/starship.toml` |
| `config/claude/settings.json` | `~/.claude/settings.json` |
| `scripts/tmux-autostart.sh` | `~/scripts/tmux-autostart.sh` |

Create any directories that don't exist yet:

```bash
mkdir -p ~/.config
mkdir -p ~/.claude
mkdir -p ~/scripts
```

### 4. Make the tmux script executable

```bash
chmod +x ~/scripts/tmux-autostart.sh
```

### 5. Open a new terminal

Ghostty will launch, tmux auto-starts with a single `home` window, and the Starship prompt appears. Everything should be live.

---

## Updating an existing machine

If the machine already has a partial setup, avoid blindly overwriting config files — they may have diverged with machine-specific content you'd lose.

**Diff before you copy.** For any file that might already exist, compare first:

```bash
diff ~/.zshrc ~/path/to/new/.zshrc
diff ~/.vimrc ~/path/to/new/.vimrc
diff ~/.config/starship.toml ~/path/to/new/config/starship.toml
```

**Files most likely to have diverged**

- `.zshrc` — may contain machine-specific PATH exports (e.g. bun, libpq) or other tooling that isn't in the new version. Rather than overwriting, apply just the missing pieces surgically: the `compinit` line near the top, the cached `BREW_PREFIX`, and `zsh-syntax-highlighting` sourced last.
- `.gitconfig` — may already have `user.name`, `user.email`, signing, push, credential, or include settings. The installer merges only aliases and preserves other sections.

**Files that are likely safe to overwrite**

- `starship.toml` — the new version is a superset of the pure preset, adding only the Claude Code status line config. Low risk.
- `.vimrc` — only comments were added; the settings themselves are unchanged.
- `tmux-autostart.sh` — the new version is the generic single-window variant. If a machine already has a custom layout, keep it.

**Files likely missing entirely**

- `~/.claude/settings.json` — probably doesn't exist if Claude Code hasn't been configured. Safe to copy directly.

**asdf**

If asdf is already installed with plugins and versions configured, `brew bundle` will skip it. Don't reinstall or reconfigure it.

---

## Notes

### tmux layout
The generic `tmux-autostart.sh` included here opens a single window at `~`. This is intentional — it makes no assumptions about repo layout on the new machine. If you want a multi-window layout, edit `~/scripts/tmux-autostart.sh` after setup.

### asdf
Only asdf itself is installed via the Brewfile. Language plugins (node, ruby, python, etc.) are left for manual setup since they vary by project. To add a plugin:

```bash
asdf plugin add nodejs
asdf install nodejs latest
```

### gitconfig
The `.gitconfig` here only contains aliases. Git will prompt for your name and email on first commit if they aren't already set. To set them:

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

### Ghostty
No custom Ghostty config is included — Starship handles all prompt styling. Font selection (JetBrains Mono Nerd Font) may need to be set manually in Ghostty's settings if it doesn't pick it up automatically.
