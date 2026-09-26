#!/usr/bin/env bash

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE="$(mktemp -d "${TMPDIR:-/tmp}/gmaya-popup-themes.XXXXXX")"
trap 'rm -rf "$FIXTURE"' EXIT
PLUGIN_SOURCE="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy"

if [[ ! -d $PLUGIN_SOURCE ]]; then
  printf 'Neovim plugins are not installed at %s\n' "$PLUGIN_SOURCE" >&2
  exit 1
fi

mkdir -p "$FIXTURE/.config" "$FIXTURE/home" "$FIXTURE/data/nvim"
ln -s "$PLUGIN_SOURCE" "$FIXTURE/data/nvim/lazy"
cp -R "$REPO/.config/nvim" "$FIXTURE/.config/nvim"
cp -R "$REPO/.config/btop" "$FIXTURE/.config/btop"
for rel in \
  .theme \
  .zshrc \
  .tmux.conf \
  .config/gmaya/work-shell.zsh \
  .config/ghostty/config \
  .config/starship.toml; do
  mkdir -p "$FIXTURE/$(dirname "$rel")"
  cp "$REPO/$rel" "$FIXTURE/$rel"
done
cp "$REPO/theme.sh" "$FIXTURE/theme.sh"

cd "$FIXTURE"
for theme in \
  latte mocha macchiato \
  tokyonight-moon tokyonight-day \
  rose-pine rose-pine-dawn; do
  "$FIXTURE/theme.sh" "$theme" > /dev/null
  if HOME="$FIXTURE/home" \
    XDG_CONFIG_HOME="$FIXTURE/.config" \
    XDG_DATA_HOME="$FIXTURE/data" \
    XDG_CACHE_HOME="$FIXTURE/cache" \
    XDG_STATE_HOME="$FIXTURE/state" \
    GMAYA_THEME_UNDER_TEST="$theme" \
    GMAYA_THEME_ASSERT_SCRIPT="$REPO/tests/nvim_popup_theme_assert.lua" \
    nvim --headless . \
      '+lua dofile(vim.env.GMAYA_THEME_ASSERT_SCRIPT)' \
      '+qa!' > "$FIXTURE/output" 2>&1; then
    printf 'ok - %s popup palette\n' "$theme"
  else
    printf 'not ok - %s popup palette\n' "$theme" >&2
    sed -n '1,20p' "$FIXTURE/output" >&2
    exit 1
  fi
done
