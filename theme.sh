#!/usr/bin/env bash

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_FILE="$REPO/.theme"
FILES=(
  .zshrc
  .config/gmaya/work-shell.zsh
  .tmux.conf
  .config/ghostty/config
  .config/starship.toml
  .config/btop/btop.conf
  .config/nvim/lua/plugins/colorscheme.lua
  .config/nvim/lua/plugins/bufferline.lua
  .config/nvim/lua/core/picker.lua
)

usage() {
  printf 'Usage: %s [status|latte|mocha|macchiato|tokyonight-moon|tokyonight-day|rose-pine|rose-pine-dawn|everforest-light|everforest-dark|kanagawa-dragon|oxocarbon-dark|zenbones-light]\n' "$0"
  printf 'Change the shared theme in every configured application.\n'
}

palette() {
  case "$1" in
    zenbones-light)
      # Zenbones Light's upstream terminal palette, with derived UI shades.
      printf '%s' '#ab6b58|#b47b70|#995d8c|#88507d|#a8334c|#94253e|#944927|#803d1c|#4f6c31|#3f5a22|#3b8992|#2b747c|#286486|#1d5573|#2c363c|#4f5e68|#63717a|#78838b|#948b85|#b5a7a0|#c4b8b1|#cfc1ba|#dfd9d6|#f0edec|#e6e1df|#e8e4e3'
      ;;
    latte)
      printf '%s' '#dc8a78|#dd7878|#ea76cb|#8839ef|#d20f39|#e64553|#fe640b|#df8e1d|#40a02b|#179299|#04a5e5|#209fb5|#1e66f5|#7287fd|#4c4f69|#5c5f77|#6c6f85|#7c7f93|#8c8fa1|#9ca0b0|#acb0be|#bcc0cc|#ccd0da|#eff1f5|#e6e9ef|#dce0e8'
      ;;
    mocha)
      printf '%s' '#f5e0dc|#f2cdcd|#f5c2e7|#cba6f7|#f38ba8|#eba0ac|#fab387|#f9e2af|#a6e3a1|#94e2d5|#89dceb|#74c7ec|#89b4fa|#b4befe|#cdd6f4|#bac2de|#a6adc8|#9399b2|#7f849c|#6c7086|#585b70|#45475a|#313244|#1e1e2e|#181825|#11111b'
      ;;
    macchiato)
      printf '%s' '#f4dbd6|#f0c6c6|#f5bde6|#c6a0f6|#ed8796|#ee99a0|#f5a97f|#eed49f|#a6da95|#8bd5ca|#91d7e3|#7dc4e4|#8aadf4|#b7bdf8|#cad3f5|#b8c0e0|#a5adcb|#939ab7|#8087a2|#6e738d|#5b6078|#494d64|#363a4f|#24273a|#1e2030|#181926'
      ;;
    tokyonight-moon)
      # Semantic equivalents from Tokyo Night's official Moon palette.
      printf '%s' '#fca7ea|#c099ff|#ff007c|#b4f9f8|#ff757f|#c53b53|#ff966c|#ffc777|#c3e88d|#4fd6be|#86e1fc|#65bcff|#82aaff|#89ddff|#c8d3f5|#737aa2|#828bb8|#636da6|#545c7e|#444a73|#3b4261|#394b70|#2d3f76|#222436|#1e2030|#191B29'
      ;;
    tokyonight-day)
      # Semantic equivalents from Tokyo Night Day; extra UI shades are interpolated.
      printf '%s' '#b4657a|#c77b80|#9854f1|#7847bd|#f52a65|#c64343|#b15c00|#8c6c3e|#587539|#118c74|#07879d|#006a83|#2e7de9|#7890dd|#3760bf|#6172b0|#848cb5|#8990b3|#a1a6c5|#a8aecb|#b3b9d0|#c4c8da|#cbd0df|#e1e2e7|#d0d5e3|#c1c9df'
      ;;
    rose-pine)
      # Rosé Pine Main with distinct derived shades for the shared 26-color UI.
      printf '%s' '#f2d3d0|#ebbcba|#dc91ae|#c4a7e7|#eb6f92|#d45b7d|#e8a987|#f6c177|#95b1ac|#31748f|#a8d9e0|#6aaac0|#9ccfd8|#b6a1d2|#e0def4|#cbc8de|#b4b0c7|#908caa|#6e6a86|#524f67|#403d52|#26233a|#21202e|#191724|#16141f|#121019'
      ;;
    rose-pine-dawn)
      # Rosé Pine Dawn with distinct derived shades for the shared 26-color UI.
      printf '%s' '#e5aaa0|#d7827e|#c27394|#907aa9|#b4637a|#a74e68|#dc8c5a|#ea9d34|#6d8f89|#286983|#6aaab2|#438797|#56949f|#a18bb4|#575279|#66617e|#797593|#89859b|#9893a5|#b7b0b8|#cecacd|#dfdad9|#f4ede8|#faf4ed|#f8f0e7|#ece4dc'
      ;;
    everforest-light)
      # Everforest Light Medium, with a few derived semantic shades for this UI.
      printf '%s' '#e66868|#e67e80|#df69ba|#b16286|#f85552|#d75f5f|#f57d26|#dfa000|#8da101|#35a77c|#66a7b5|#4a9aa7|#3a94c5|#a882b0|#5c6a72|#708089|#829181|#939f91|#a6b0a0|#bdc3af|#e0dcc7|#e6e2cc|#efebd4|#fdf6e3|#f4f0d9|#e9e5cf'
      ;;
    everforest-dark)
      # Everforest Dark Hard, with distinct derived semantic shades for this UI.
      printf '%s' '#e69875|#e67e80|#d699b6|#bb8aac|#ef7b83|#c56b73|#e29a73|#dbbc7f|#a7c080|#83c092|#91c8c1|#6caaa4|#7fbbb3|#a9a6c2|#d3c6aa|#c4bba4|#9da9a0|#859289|#7a8478|#687a74|#495156|#414b50|#374145|#272e33|#2e383c|#1e2326'
      ;;
    kanagawa-dragon)
      # Kanagawa Dragon; the peach and UI shades are semantic equivalents.
      printf '%s' '#b6927b|#b98d7b|#a292a3|#8992a7|#c4746e|#e46876|#d79a7d|#c4b28a|#8a9a7b|#87a987|#8ea4a2|#658594|#8ba4b0|#949fb5|#c5c9c5|#c8c093|#a6a69c|#9e9b93|#7a8382|#737c73|#393836|#282727|#1d1c19|#181616|#12120f|#0d0c0c'
      ;;
    oxocarbon-dark)
      # Official Oxocarbon Base16 colors plus nearby Carbon shades for the
      # shared 26-slot UI. Keep entries unique so theme switches round-trip.
      printf '%s' '#ffb3d6|#ff7eb6|#ee5396|#be95ff|#fa4d56|#da1e28|#ff832b|#f1c21b|#42be65|#08bdba|#3ddbd9|#82cfff|#78a9ff|#a6c8ff|#f2f4f8|#dde1e6|#c1c7cd|#8d8d8d|#6f6f6f|#525252|#393939|#303030|#262626|#161616|#1f1f1f|#0f0f0f'
      ;;
    *) return 1 ;;
  esac
}

display_name() {
  case "$1" in
    zenbones-light) printf 'Zenbones Light' ;;
    latte) printf 'Catppuccin Latte' ;;
    mocha) printf 'Catppuccin Mocha' ;;
    macchiato) printf 'Catppuccin Macchiato' ;;
    tokyonight-moon) printf 'TokyoNight Moon' ;;
    tokyonight-day) printf 'TokyoNight Day' ;;
    rose-pine) printf 'Rose Pine' ;;
    rose-pine-dawn) printf 'Rose Pine Dawn' ;;
    everforest-light) printf 'Everforest Light Med' ;;
    everforest-dark) printf 'Everforest Dark Hard' ;;
    kanagawa-dragon) printf 'Kanagawa Dragon' ;;
    oxocarbon-dark) printf 'Oxocarbon' ;;
    *) return 1 ;;
  esac
}

config_slug() {
  case "$1" in
    zenbones-light) printf 'zenbones_light' ;;
    latte|mocha|macchiato) printf 'catppuccin_%s' "$1" ;;
    tokyonight-moon) printf 'tokyonight_moon' ;;
    tokyonight-day) printf 'tokyonight_day' ;;
    rose-pine) printf 'rose_pine' ;;
    rose-pine-dawn) printf 'rose_pine_dawn' ;;
    everforest-light) printf 'everforest_light' ;;
    everforest-dark) printf 'everforest_dark' ;;
    kanagawa-dragon) printf 'kanagawa_dragon' ;;
    oxocarbon-dark) printf 'oxocarbon_dark' ;;
    *) return 1 ;;
  esac
}

bat_theme() {
  case "$1" in
    latte) printf 'Catppuccin Latte' ;;
    mocha) printf 'Catppuccin Mocha' ;;
    macchiato) printf 'Catppuccin Macchiato' ;;
    tokyonight-moon|tokyonight-day|rose-pine|rose-pine-dawn|everforest-light|everforest-dark|kanagawa-dragon|oxocarbon-dark|zenbones-light) printf 'ansi' ;;
    *) return 1 ;;
  esac
}

verify_selection() {
  local root="$1" theme="$2" display slug bat
  display="$(display_name "$theme")"
  slug="$(config_slug "$theme")"
  bat="$(bat_theme "$theme")"
  [[ $(tr -d '[:space:]' < "$root/.theme") == "$theme" ]] || return 1
  grep -Fq "BAT_THEME=\"$bat\"" "$root/.zshrc" || return 1
  grep -Fq "BAT_THEME=\"$bat\"" \
    "$root/.config/gmaya/work-shell.zsh" || return 1
  grep -Fq "palette = '$slug'" \
    "$root/.config/starship.toml" || return 1
  grep -Fq "[palettes.$slug]" \
    "$root/.config/starship.toml" || return 1
  grep -Fq "selected_theme = \"$theme\"" \
    "$root/.config/nvim/lua/plugins/colorscheme.lua" || return 1
  grep -Fq "@gmaya_theme \"$theme\"" \
    "$root/.tmux.conf" || return 1
  grep -Fq "theme = \"$display\"" \
    "$root/.config/ghostty/config" || return 1
  grep -Fq "color_theme = \"$slug\"" \
    "$root/.config/btop/btop.conf" || return 1
  [[ -f $root/.config/btop/themes/$slug.theme ]] || return 1
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
    printf '%s is selected everywhere.\n' "$(display_name "$CURRENT")"
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
  printf '%s is already selected everywhere.\n' "$(display_name "$CURRENT")"
  exit 0
fi

FROM_COLORS="$(palette "$CURRENT")"
TO_COLORS="$(palette "$ACTION")"
FROM_DISPLAY="$(display_name "$CURRENT")"
TO_DISPLAY="$(display_name "$ACTION")"
FROM_SLUG="$(config_slug "$CURRENT")"
TO_SLUG="$(config_slug "$ACTION")"
FROM_BAT="$(bat_theme "$CURRENT")"
TO_BAT="$(bat_theme "$ACTION")"
STAGE="$(mktemp -d "${TMPDIR:-/tmp}/gmaya-theme.XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT

# Static btop palettes are not rewritten during a switch, but stage the target
# asset so validation proves the selected configuration is complete.
mkdir -p "$STAGE/.config/btop/themes"
cp "$REPO/.config/btop/themes/$TO_SLUG.theme" \
  "$STAGE/.config/btop/themes/$TO_SLUG.theme"

for rel in "${FILES[@]}"; do
  [[ -f $REPO/$rel ]] || {
    printf 'Required theme file is missing: %s\n' "$REPO/$rel" >&2
    exit 1
  }
  mkdir -p "$STAGE/$(dirname "$rel")"
  awk \
    -v from_colors="$FROM_COLORS" \
    -v to_colors="$TO_COLORS" \
    -v from_theme="$CURRENT" \
    -v to_theme="$ACTION" \
    -v from_display="$FROM_DISPLAY" \
    -v to_display="$TO_DISPLAY" \
    -v from_slug="$FROM_SLUG" \
    -v to_slug="$TO_SLUG" \
    -v from_bat="$FROM_BAT" \
    -v to_bat="$TO_BAT" '
      BEGIN {
        count_from = split(from_colors, old, "|")
        count_to = split(to_colors, new, "|")
        if (count_from != count_to) exit 70
      }
      {
        gsub("BAT_THEME=\"" from_bat "\"", "BAT_THEME=\"" to_bat "\"")
        gsub(from_slug, to_slug)
        gsub(from_display, to_display)
        gsub("selected_theme = \"" from_theme "\"", "selected_theme = \"" to_theme "\"")
        gsub("@gmaya_theme \"" from_theme "\"", "@gmaya_theme \"" to_theme "\"")
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

printf 'Changed every configured application to %s.\n' "$TO_DISPLAY"
printf 'Reload the shell and tmux config; restart other open applications.\n'
