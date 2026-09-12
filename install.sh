#!/usr/bin/env bash
#
# Link this repo's configs into $HOME.
#
# Unlike a copying installer, this creates symlinks: the file in the repo IS
# the file the tool reads. Edit either path and both are current, and git
# always sees the change. There is no separate "capture" step to forget.
#
#   ./install.sh          report what would happen; change nothing
#   ./install.sh --apply  link only paths that do not already exist
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE=check
case "${1:-}" in
  ""|--check|--dry-run) ;;
  --apply) MODE=apply ;;
  -h|--help)
    printf 'Usage: %s [--check|--dry-run|--apply]\n' "$0"
    printf '  --check, --dry-run  report without changing anything (default)\n'
    printf '  --apply             link missing paths; never replace existing paths\n'
    exit 0
    ;;
  *)
    printf 'Unknown option: %s\n' "$1" >&2
    exit 2
    ;;
esac

FILES=(
  .zshrc
  .zprofile
  .tmux.conf
  .gitconfig
  .config/starship.toml
  .config/ghostty
  .config/nvim
  .config/btop
)

check_or_link() {
  local rel="$1"
  local src="$REPO/$rel"
  local dst="$HOME/$rel"

  [[ -e "$src" ]] || { printf '  skip     %s (not in repo)\n' "$rel"; return; }

  # Already pointing where we want it.
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    printf '  ok       %s\n' "$rel"
    return
  fi

  # Any existing path is a conflict. The installer never moves or replaces it.
  if [[ -e "$dst" || -L "$dst" ]]; then
    printf '  CONFLICT %s already exists — left unchanged\n' "$rel"
    return
  fi

  if [[ "$MODE" == check ]]; then
    printf '  would link %s\n' "$rel"
    return
  fi

  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  printf '  linked   %s\n' "$rel"
}

if [[ "$MODE" == check ]]; then
  printf 'Checking dotfiles from %s (read-only)\n\n' "$REPO"
else
  printf 'Linking missing dotfiles from %s\n\n' "$REPO"
fi
for f in "${FILES[@]}"; do check_or_link "$f"; done

printf '\n%s. Secrets and account credentials are not managed here.\n' \
  "$([[ "$MODE" == check ]] && printf 'Check complete; nothing changed' || printf 'Done')"
printf '~/.zshsecrets is sourced when present and remains deliberately gitignored.\n'
