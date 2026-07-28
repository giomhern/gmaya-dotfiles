#!/usr/bin/env bash
#
# Link this repo's configs into $HOME.
#
# Unlike a copying installer, this creates symlinks: the file in the repo IS
# the file the tool reads. Edit either path and both are current, and git
# always sees the change. There is no separate "capture" step to forget.
#
#   ./install.sh          link everything, skipping anything already correct
#   ./install.sh --force  replace existing real files (backed up first)
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORCE=0
[[ "${1:-}" == "--force" ]] && FORCE=1

STAMP="$(date +%Y%m%d-%H%M%S)"

FILES=(
  .zshrc
  .zshenv
  .zprofile
  .tmux.conf
  .gitconfig
  .config/starship.toml
  .config/ghostty
  .config/nvim
  .config/btop
)

link() {
  local rel="$1"
  local src="$REPO/$rel"
  local dst="$HOME/$rel"

  [[ -e "$src" ]] || { printf '  skip     %s (not in repo)\n' "$rel"; return; }

  # Already pointing where we want it.
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    printf '  ok       %s\n' "$rel"
    return
  fi

  # Something real is in the way. Never destroy it silently.
  if [[ -e "$dst" || -L "$dst" ]]; then
    if (( FORCE )); then
      mv "$dst" "$dst.bak.$STAMP"
      printf '  backed   %s -> %s.bak.%s\n' "$rel" "$rel" "$STAMP"
    else
      printf '  CONFLICT %s already exists — rerun with --force to replace\n' "$rel"
      return
    fi
  fi

  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  printf '  linked   %s\n' "$rel"
}

printf 'Linking dotfiles from %s\n\n' "$REPO"
for f in "${FILES[@]}"; do link "$f"; done

printf '\nDone. Secrets are not managed here — .zshrc reads ~/.secrets/github.com\n'
printf 'and ~/.zshsecrets if they exist, both deliberately gitignored.\n'
