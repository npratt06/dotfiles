#!/usr/bin/env zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APPLY=0
SHOW_DIFF=0
SKIP_CLAUDE=0
BACKUP_DIR="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  BOLD=$'\033[1m'
  DIM=$'\033[2m'
  GREEN=$'\033[32m'
  YELLOW=$'\033[33m'
  BLUE=$'\033[34m'
  RESET=$'\033[0m'
else
  BOLD=""
  DIM=""
  GREEN=""
  YELLOW=""
  BLUE=""
  RESET=""
fi

usage() {
  cat <<'USAGE'
Usage: ./scripts/install.sh [--apply] [--diff] [--skip-claude]

Without --apply, prints a readable dry-run summary.
Use --diff to include full unified diffs in the dry run.
Use --skip-claude to omit Claude Code settings.
With --apply, backs up existing files and copies dotfiles into place.
USAGE
}

for arg in "$@"; do
  case "$arg" in
    --apply)
      APPLY=1
      ;;
    --diff)
      SHOW_DIFF=1
      ;;
    --skip-claude)
      SKIP_CLAUDE=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      usage >&2
      exit 1
      ;;
  esac
done

files=(
  ".zshrc:$HOME/.zshrc"
  ".vimrc:$HOME/.vimrc"
  "config/starship.toml:$HOME/.config/starship.toml"
  "scripts/tmux-autostart.sh:$HOME/scripts/tmux-autostart.sh"
)

if [[ "$SKIP_CLAUDE" -eq 0 ]]; then
  files+=("config/claude/settings.json:$HOME/.claude/settings.json")
fi

display_path() {
  local path="$1"
  echo "${path/#$HOME/~}"
}

status_line() {
  local color="$1"
  local label="$2"
  local dest="$3"
  local src="$4"
  local details="${5:-}"

  printf "%s%-10s%s %s\n" "$color" "$label" "$RESET" "$(display_path "$dest")"
  printf "  %srepo:%s %s\n" "$DIM" "$RESET" "${src/#$ROOT_DIR\//}"
  if [[ -n "$details" ]]; then
    printf "  %s%s%s\n" "$DIM" "$details" "$RESET"
  fi
}

diff_summary() {
  local dest="$1"
  local src="$2"
  diff -u "$dest" "$src" | awk '
    /^--- / || /^\+\+\+ / { next }
    /^\+/ { additions++ }
    /^-/ { deletions++ }
    END {
      printf "%d additions, %d deletions", additions + 0, deletions + 0
    }
  '
}

render_diff() {
  local dest="$1"
  local src="$2"
  local color_arg="--color=never"

  if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    color_arg="--color=always"
  fi

  if command -v git >/dev/null 2>&1; then
    git diff --no-index "$color_arg" -- "$dest" "$src" || true
    return
  fi

  diff -u "$dest" "$src" || true
}

repo_git_aliases() {
  awk '
    /^[[:space:]]*\[/ {
      in_alias = ($0 ~ /^[[:space:]]*\[alias\][[:space:]]*$/)
      next
    }
    in_alias && /^[[:space:]]*[^#;[:space:]][^=]*=/ {
      key = $0
      sub(/=.*/, "", key)
      gsub(/^[ \t]+|[ \t]+$/, "", key)

      value = $0
      sub(/^[^=]*=/, "", value)
      gsub(/^[ \t]+|[ \t]+$/, "", value)

      print key "\t" value
    }
  ' "$ROOT_DIR/.gitconfig"
}

preview_gitconfig() {
  local src="$ROOT_DIR/.gitconfig"
  local dest="$HOME/.gitconfig"
  local alias_name
  local alias_value
  local current_value
  local action

  status_line "$YELLOW" "MERGE" "$dest" "$src" "aliases only; other sections are preserved"

  if ! command -v git >/dev/null 2>&1; then
    printf "  %sGit is required to preview current global aliases.%s\n" "$DIM" "$RESET"
    while IFS=$'\t' read -r alias_name alias_value; do
      printf "  alias.%s = %s\n" "$alias_name" "$alias_value"
    done < <(repo_git_aliases)
    return
  fi

  while IFS=$'\t' read -r alias_name alias_value; do
    current_value="$(git config --global --get "alias.$alias_name" 2>/dev/null || true)"

    if [[ "$current_value" == "$alias_value" ]]; then
      action="UNCHANGED"
    elif [[ -z "$current_value" ]]; then
      action="SET"
    else
      action="UPDATE"
    fi

    printf "  %-10s alias.%s = %s\n" "$action" "$alias_name" "$alias_value"
  done < <(repo_git_aliases)
}

install_gitconfig() {
  local dest="$HOME/.gitconfig"
  local alias_name
  local alias_value

  if ! command -v git >/dev/null 2>&1; then
    echo "Git is required to merge .gitconfig aliases." >&2
    return 1
  fi

  ensure_parent_dir "$dest"
  backup_existing "$dest"

  while IFS=$'\t' read -r alias_name alias_value; do
    git config --global "alias.$alias_name" "$alias_value"
    echo "Set git alias.$alias_name"
  done < <(repo_git_aliases)
}

ensure_parent_dir() {
  local dest="$1"
  mkdir -p "$(dirname "$dest")"
}

backup_existing() {
  local dest="$1"
  if [[ -e "$dest" || -L "$dest" ]]; then
    mkdir -p "$BACKUP_DIR$(dirname "$dest")"
    cp -p "$dest" "$BACKUP_DIR$dest"
    echo "Backed up $dest"
  fi
}

preview_file() {
  local src="$1"
  local dest="$2"

  if [[ ! -e "$dest" ]]; then
    status_line "$BLUE" "CREATE" "$dest" "$src"
    return
  fi

  if cmp -s "$src" "$dest"; then
    status_line "$GREEN" "UNCHANGED" "$dest" "$src"
    return
  fi

  status_line "$YELLOW" "UPDATE" "$dest" "$src" "$(diff_summary "$dest" "$src")"

  if [[ "$SHOW_DIFF" -eq 1 ]]; then
    echo
    printf "%sDiff: %s%s\n" "$BOLD" "$(display_path "$dest")" "$RESET"
    render_diff "$dest" "$src"
    echo
  fi
}

install_file() {
  local src="$1"
  local dest="$2"

  ensure_parent_dir "$dest"
  backup_existing "$dest"
  cp "$src" "$dest"
  echo "Installed $dest"
}

if [[ "$APPLY" -eq 0 ]]; then
  printf "%sDotfiles dry run%s\n" "$BOLD" "$RESET"
  echo "Dry-run only; no files will be changed."
  if [[ "$SKIP_CLAUDE" -eq 1 ]]; then
    echo "Skipping Claude Code settings."
  fi
  echo
fi

if [[ "$APPLY" -eq 1 ]]; then
  install_gitconfig
else
  preview_gitconfig
fi

for mapping in "${files[@]}"; do
  src="${mapping%%:*}"
  dest="${mapping#*:}"
  src="$ROOT_DIR/$src"

  if [[ "$APPLY" -eq 1 ]]; then
    install_file "$src" "$dest"
  else
    preview_file "$src" "$dest"
  fi
done

if [[ "$APPLY" -eq 1 ]]; then
  chmod +x "$HOME/scripts/tmux-autostart.sh"
  echo "Install complete."
  echo "Backups, if any, are in $BACKUP_DIR"
else
  echo
  echo "Dry run complete. Re-run with --apply to copy files."
  echo "Use --diff to include full unified diffs."
  echo "Use --skip-claude to omit Claude Code settings."
fi
