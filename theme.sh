#!/usr/bin/env bash

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_FILE="$REPO/.theme"
FILES=(
  .zshrc
  .tmux.conf
  .config/ghostty/config
  .config/starship.toml
  .config/btop/btop.conf
  .config/nvim/init.lua
  .config/nvim/lua/core/picker.lua
)

usage() {
  printf 'Usage: %s [status|mocha|macchiato]\n' "$0"
  printf 'Change the Catppuccin flavor in every themed application.\n'
}

palette() {
  case "$1" in
    mocha)
      printf '%s' '#f5e0dc|#f2cdcd|#f5c2e7|#cba6f7|#f38ba8|#eba0ac|#fab387|#f9e2af|#a6e3a1|#94e2d5|#89dceb|#74c7ec|#89b4fa|#b4befe|#cdd6f4|#bac2de|#a6adc8|#9399b2|#7f849c|#6c7086|#585b70|#45475a|#313244|#1e1e2e|#181825|#11111b'
      ;;
    macchiato)
      printf '%s' '#f4dbd6|#f0c6c6|#f5bde6|#c6a0f6|#ed8796|#ee99a0|#f5a97f|#eed49f|#a6da95|#8bd5ca|#91d7e3|#7dc4e4|#8aadf4|#b7bdf8|#cad3f5|#b8c0e0|#a5adcb|#939ab7|#8087a2|#6e738d|#5b6078|#494d64|#363a4f|#24273a|#1e2030|#181926'
      ;;
    *) return 1 ;;
  esac
}

title() {
  case "$1" in
    mocha) printf 'Mocha' ;;
    macchiato) printf 'Macchiato' ;;
    *) return 1 ;;
  esac
}

verify_selection() {
  local root="$1" flavor="$2" display
  display="$(title "$flavor")"
  [[ $(tr -d '[:space:]' < "$root/.theme") == "$flavor" ]] || return 1
  grep -Fq "BAT_THEME=\"Catppuccin $display\"" "$root/.zshrc" || return 1
  grep -Fq "palette = 'catppuccin_$flavor'" \
    "$root/.config/starship.toml" || return 1
  grep -Fq "[palettes.catppuccin_$flavor]" \
    "$root/.config/starship.toml" || return 1
  grep -Fq "flavour = \"$flavor\"" \
    "$root/.config/nvim/init.lua" || return 1
  grep -Fq "@catppuccin_flavor \"$flavor\"" \
    "$root/.tmux.conf" || return 1
  grep -Fq "theme = \"Catppuccin $display\"" \
    "$root/.config/ghostty/config" || return 1
  grep -Fq "color_theme = \"catppuccin_$flavor\"" \
    "$root/.config/btop/btop.conf" || return 1
}

CURRENT="$(tr -d '[:space:]' < "$THEME_FILE")"
palette "$CURRENT" >/dev/null || {
  printf 'Unknown flavor in %s: %s\n' "$THEME_FILE" "$CURRENT" >&2
  exit 1
}

ACTION="${1:-status}"
if (( $# > 1 )); then
  usage >&2
  exit 2
fi

if [[ $ACTION == status ]]; then
  if verify_selection "$REPO" "$CURRENT"; then
    printf 'Catppuccin %s is selected everywhere.\n' "$(title "$CURRENT")"
  else
    printf 'Theme files do not agree with %s. Run %s %s to repair them.\n' \
      "$THEME_FILE" "$0" "$CURRENT" >&2
    exit 1
  fi
  exit 0
fi

palette "$ACTION" >/dev/null || {
  printf 'Unsupported flavor: %s\n\n' "$ACTION" >&2
  usage >&2
  exit 2
}

verify_selection "$REPO" "$CURRENT" || {
  printf 'Refusing to switch because the current theme files are inconsistent.\n' >&2
  printf 'Review the theme-related edits before trying again.\n' >&2
  exit 1
}

if [[ $ACTION == "$CURRENT" ]]; then
  printf 'Catppuccin %s is already selected everywhere.\n' "$(title "$CURRENT")"
  exit 0
fi

FROM_COLORS="$(palette "$CURRENT")"
TO_COLORS="$(palette "$ACTION")"
FROM_TITLE="$(title "$CURRENT")"
TO_TITLE="$(title "$ACTION")"
STAGE="$(mktemp -d "${TMPDIR:-/tmp}/gmaya-theme.XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT

for rel in "${FILES[@]}"; do
  [[ -f $REPO/$rel ]] || {
    printf 'Required theme file is missing: %s\n' "$REPO/$rel" >&2
    exit 1
  }
  mkdir -p "$STAGE/$(dirname "$rel")"
  awk \
    -v from_colors="$FROM_COLORS" \
    -v to_colors="$TO_COLORS" \
    -v from_flavor="$CURRENT" \
    -v to_flavor="$ACTION" \
    -v from_title="$FROM_TITLE" \
    -v to_title="$TO_TITLE" '
      BEGIN {
        count_from = split(from_colors, old, "|")
        count_to = split(to_colors, new, "|")
        if (count_from != count_to) exit 70
      }
      {
        gsub("catppuccin_" from_flavor, "catppuccin_" to_flavor)
        gsub("Catppuccin " from_title, "Catppuccin " to_title)
        gsub("\"" from_flavor "\"", "\"" to_flavor "\"")
        for (i = 1; i <= count_from; i++) {
          gsub(old[i], "__GMAYA_THEME_COLOR_" i "__")
        }
        for (i = 1; i <= count_to; i++) {
          gsub("__GMAYA_THEME_COLOR_" i "__", new[i])
        }
        print
      }
    ' "$REPO/$rel" > "$STAGE/$rel"
done
printf '%s\n' "$ACTION" > "$STAGE/.theme"

verify_selection "$STAGE" "$ACTION" || {
  printf 'Generated theme failed validation; repository was not changed.\n' >&2
  exit 1
}

for rel in "${FILES[@]}"; do
  cat "$STAGE/$rel" > "$REPO/$rel"
done
cat "$STAGE/.theme" > "$THEME_FILE"

printf 'Changed every configured application to Catppuccin %s.\n' \
  "$TO_TITLE"
printf 'Reload the shell and tmux config; restart other open applications.\n'
