#!/usr/bin/env bash

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE="$(mktemp -d "${TMPDIR:-/tmp}/gmaya-theme-tests.XXXXXX")"
trap 'rm -rf "$FIXTURE"' EXIT

FILES=(
  .theme
  .zshrc
  .tmux.conf
  .config/ghostty/config
  .config/starship.toml
  .config/btop/btop.conf
  .config/nvim/init.lua
  .config/nvim/lua/core/picker.lua
)

for rel in "${FILES[@]}"; do
  mkdir -p "$FIXTURE/$(dirname "$rel")"
  cp "$REPO/$rel" "$FIXTURE/$rel"
done
cp "$REPO/theme.sh" "$FIXTURE/theme.sh"
chmod +x "$FIXTURE/theme.sh"

before="$(for rel in "${FILES[@]}"; do cksum "$FIXTURE/$rel"; done)"
"$FIXTURE/theme.sh" status >/dev/null
"$FIXTURE/theme.sh" macchiato >/dev/null
"$FIXTURE/theme.sh" status | grep -Fq 'Catppuccin Macchiato'
grep -Fq '#24273a' "$FIXTURE/.zshrc"
grep -Fq 'BAT_THEME="Catppuccin Macchiato"' "$FIXTURE/.zshrc"
grep -Fq '#8aadf4' "$FIXTURE/.config/nvim/lua/core/picker.lua"
"$FIXTURE/theme.sh" mocha >/dev/null
after="$(for rel in "${FILES[@]}"; do cksum "$FIXTURE/$rel"; done)"
[[ $before == "$after" ]]

if "$FIXTURE/theme.sh" unsupported >/dev/null 2>&1; then
  exit 1
fi

printf '\n# local theme edit\n' >> "$FIXTURE/.config/ghostty/config"
sed 's/Catppuccin Mocha/Catppuccin Macchiato/' \
  "$FIXTURE/.config/ghostty/config" > "$FIXTURE/ghostty.changed"
cat "$FIXTURE/ghostty.changed" > "$FIXTURE/.config/ghostty/config"
before_refusal="$(for rel in "${FILES[@]}"; do cksum "$FIXTURE/$rel"; done)"
if "$FIXTURE/theme.sh" macchiato >/dev/null 2>&1; then
  exit 1
fi
after_refusal="$(for rel in "${FILES[@]}"; do cksum "$FIXTURE/$rel"; done)"
[[ $before_refusal == "$after_refusal" ]]

printf 'ok - theme switch propagates, round-trips, and refuses inconsistent input\n'
