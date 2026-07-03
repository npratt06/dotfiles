# macOS Dev Setup

Terminal setup files for bootstrapping a macOS development machine.

## Contents

| Path | Destination |
|---|---|
| `.zshrc` | `~/.zshrc` |
| `.gitconfig` | aliases merged into `~/.gitconfig` |
| `.vimrc` | `~/.vimrc` |
| `config/starship.toml` | `~/.config/starship.toml` |
| `config/claude/settings.json` | `~/.claude/settings.json` |
| `scripts/tmux-autostart.sh` | `~/scripts/tmux-autostart.sh` |
| `Brewfile` | Homebrew bundle source |

See [dev-setup.md](dev-setup.md) for the full setup notes and rationale.

## License

Released under the [MIT License](LICENSE).

## New Machine Setup

Install Homebrew first if it is not already installed:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Clone this repo:

```bash
git clone git@github.com:npratt06/dotfiles.git ~/Repos/dotfiles
cd ~/Repos/dotfiles
```

Install packages:

```bash
brew bundle --file Brewfile
```

Preview config changes:

```bash
./scripts/install.sh
```

Show full diffs:

```bash
./scripts/install.sh --diff
```

Full diffs are colorized when Git is available.

Skip Claude Code settings:

```bash
./scripts/install.sh --skip-claude
```

Apply config changes:

```bash
./scripts/install.sh --apply
```

To apply everything except Claude Code settings:

```bash
./scripts/install.sh --apply --skip-claude
```

Existing destination files are backed up under `~/.dotfiles-backups/` before they are replaced. Git aliases are merged into `~/.gitconfig` so machine-specific sections like `[user]` and `[push]` are preserved.

## Notes

Some Git aliases intentionally expose sharp operations like force-push and hard reset. Review `.gitconfig` before installing if you prefer safer aliases.

This repo intentionally does not include Git identity settings such as `user.name` or `user.email`. Set those per machine:

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```
