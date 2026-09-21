#!/usr/bin/env bash

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE="$(mktemp -d "${TMPDIR:-/tmp}/gmaya-theme-tests.XXXXXX")"
trap 'rm -rf "$FIXTURE"' EXIT

FILES=(
  .theme
  .zshrc
  .config/gmaya/work-shell.zsh
  .tmux.conf
  .config/ghostty/config
  .config/starship.toml
  .config/btop/btop.conf
  .config/btop/themes/catppuccin_latte.theme
  .config/btop/themes/catppuccin_macchiato.theme
  .config/btop/themes/catppuccin_mocha.theme
  .config/btop/themes/tokyonight_moon.theme
  .config/nvim/lua/plugins/colorscheme.lua
  .config/nvim/lua/plugins/bufferline.lua
  .config/nvim/lua/core/picker.lua
)

for rel in "${FILES[@]}"; do
  mkdir -p "$FIXTURE/$(dirname "$rel")"
  cp "$REPO/$rel" "$FIXTURE/$rel"
done
cp "$REPO/theme.sh" "$FIXTURE/theme.sh"
chmod +x "$FIXTURE/theme.sh"

before="$(for rel in "${FILES[@]}"; do cksum "$FIXTURE/$rel"; done)"
original_theme="$(tr -d '[:space:]' < "$FIXTURE/.theme")"
"$FIXTURE/theme.sh" status >/dev/null
"$FIXTURE/theme.sh" latte >/dev/null
"$FIXTURE/theme.sh" status | grep -Fq 'Catppuccin Latte'
grep -Fq 'theme = "Catppuccin Latte"' \
  "$FIXTURE/.config/ghostty/config"
grep -Fq 'selected_theme = "latte"' \
  "$FIXTURE/.config/nvim/lua/plugins/colorscheme.lua"
grep -Fq "palette = 'catppuccin_latte'" \
  "$FIXTURE/.config/starship.toml"
grep -Fq 'color_theme = "catppuccin_latte"' \
  "$FIXTURE/.config/btop/btop.conf"
grep -Fq 'theme[main_bg]="#eff1f5"' \
  "$FIXTURE/.config/btop/themes/catppuccin_latte.theme"
grep -Fq 'BAT_THEME="Catppuccin Latte"' "$FIXTURE/.zshrc"
grep -Fq 'BAT_THEME="Catppuccin Latte"' \
  "$FIXTURE/.config/gmaya/work-shell.zsh"
grep -Fq '#eff1f5' "$FIXTURE/.config/nvim/lua/core/picker.lua"
"$FIXTURE/theme.sh" macchiato >/dev/null
"$FIXTURE/theme.sh" status | grep -Fq 'Catppuccin Macchiato'
grep -Fq '#24273a' "$FIXTURE/.zshrc"
grep -Fq 'BAT_THEME="Catppuccin Macchiato"' "$FIXTURE/.zshrc"
grep -Fq '#8aadf4' "$FIXTURE/.config/nvim/lua/core/picker.lua"
"$FIXTURE/theme.sh" tokyonight-moon >/dev/null
"$FIXTURE/theme.sh" status | grep -Fq 'TokyoNight Moon'
grep -Fq 'theme = "TokyoNight Moon"' "$FIXTURE/.config/ghostty/config"
grep -Fq 'selected_theme = "tokyonight-moon"' \
  "$FIXTURE/.config/nvim/lua/plugins/colorscheme.lua"
grep -Fq 'color_theme = "tokyonight_moon"' \
  "$FIXTURE/.config/btop/btop.conf"
grep -Fq 'BAT_THEME="ansi"' "$FIXTURE/.zshrc"
grep -Fq '#222436' "$FIXTURE/.config/starship.toml"
"$FIXTURE/theme.sh" "$original_theme" >/dev/null
after="$(for rel in "${FILES[@]}"; do cksum "$FIXTURE/$rel"; done)"
if [[ $before != "$after" ]]; then
  printf 'Theme round trip did not restore the original files.\n' >&2
  exit 1
fi

if "$FIXTURE/theme.sh" unsupported >/dev/null 2>&1; then
  exit 1
fi

printf '\n# local theme edit\n' >> "$FIXTURE/.config/ghostty/config"
sed 's/^theme = .*/theme = "Definitely Inconsistent"/' \
  "$FIXTURE/.config/ghostty/config" > "$FIXTURE/ghostty.changed"
cat "$FIXTURE/ghostty.changed" > "$FIXTURE/.config/ghostty/config"
before_refusal="$(for rel in "${FILES[@]}"; do cksum "$FIXTURE/$rel"; done)"
if "$FIXTURE/theme.sh" macchiato >/dev/null 2>&1; then
  exit 1
fi
after_refusal="$(for rel in "${FILES[@]}"; do cksum "$FIXTURE/$rel"; done)"
[[ $before_refusal == "$after_refusal" ]]

printf 'ok - cross-family theme switch propagates, round-trips, and refuses inconsistent input\n'
