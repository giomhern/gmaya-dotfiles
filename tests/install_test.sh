#!/usr/bin/env bash

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL="$REPO/install.sh"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/gmaya-dotfiles-tests.XXXXXX")"
PASS_COUNT=0

cleanup() {
  rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

new_home() {
  local name="$1"
  local home="$TEST_ROOT/$name"
  mkdir -p "$home"
  printf '%s' "$home"
}

pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  printf 'ok %d - %s\n' "$PASS_COUNT" "$1"
}

assert_file_text() {
  local path="$1" expected="$2"
  [[ -f $path && $(cat "$path") == "$expected" ]]
}

assert_installed() {
  local home="$1" rel="$2"
  [[ -L $home/$rel && $(readlink "$home/$rel") == "$REPO/$rel" ]]
}

file_mode() {
  stat -f '%Lp' "$1" 2>/dev/null || stat -c '%a' "$1"
}

test_default_is_read_only() {
  local home output
  home="$(new_home default)"
  output="$(HOME="$home" "$INSTALL")"
  [[ $output == *'Check complete; nothing changed.'* ]]
  [[ ! -e $home/.zshrc && ! -e $home/.config ]]
  pass 'default mode is read-only'
}

test_apply_links_only_missing_targets() {
  local home rel
  home="$(new_home apply)"
  printf 'keep this shell\n' > "$home/.zshrc"

  HOME="$home" "$INSTALL" --apply >/dev/null
  assert_file_text "$home/.zshrc" 'keep this shell'
  [[ ! -L $home/.zshrc ]]

  for rel in .zprofile .tmux.conf .gitconfig .config/starship.toml \
    .config/ghostty .config/nvim .config/btop; do
    assert_installed "$home" "$rel"
  done
  pass '--apply preserves conflicts and links missing targets'
}

test_migrate_clean_home_needs_no_backup() {
  local home rel
  home="$(new_home migrate-clean)"
  HOME="$home" "$INSTALL" --migrate >/dev/null

  for rel in .zshrc .zprofile .tmux.conf .gitconfig .config/starship.toml \
    .config/ghostty .config/nvim .config/btop; do
    assert_installed "$home" "$rel"
  done
  [[ ! -e $home/.dotfiles-backups ]]
  pass '--migrate on a clean home links without creating an empty backup'
}

test_migrate_preserves_and_backs_up() {
  local home backup rel
  home="$(new_home migrate)"
  mkdir -p "$home/.config/ghostty" "$home/.config/nvim" \
    "$home/.config/btop" "$home/.ssh" "$home/.gnupg" "$home/.config/gh" \
    "$home/.aws" "$home/.kube" "$home/.secrets"

  printf 'old shell\n' > "$home/.zshrc"
  printf 'old profile\n' > "$home/.zprofile"
  printf '[user]\n\tname = Existing User\n' > "$home/.gitconfig"
  printf 'old tmux\n' > "$home/.tmux.conf"
  printf 'old starship\n' > "$home/.config/starship.toml"
  printf 'old ghostty\n' > "$home/.config/ghostty/config"
  printf 'old nvim\n' > "$home/.config/nvim/init.lua"
  printf 'old btop\n' > "$home/.config/btop/btop.conf"

  printf 'ssh-secret\n' > "$home/.ssh/id_test"
  printf 'gh-secret\n' > "$home/.config/gh/hosts.yml"
  printf 'aws-secret\n' > "$home/.aws/credentials"
  printf 'gpg-secret\n' > "$home/.gnupg/private-key"
  printf 'kube-secret\n' > "$home/.kube/config"
  printf 'shell-secret\n' > "$home/.zshsecrets"
  printf 'netrc-secret\n' > "$home/.netrc"
  printf 'git-secret\n' > "$home/.git-credentials"
  printf 'other-secret\n' > "$home/.secrets/account"

  HOME="$home" "$INSTALL" --migrate >/dev/null

  for rel in .zshrc .zprofile .tmux.conf .gitconfig .config/starship.toml \
    .config/ghostty .config/nvim .config/btop; do
    assert_installed "$home" "$rel"
  done

  assert_file_text "$home/.zshrc.local" 'old shell'
  assert_file_text "$home/.zprofile.local" 'old profile'
  assert_file_text "$home/.gitconfig.local" $'[user]\n\tname = Existing User'
  [[ $(HOME="$home" git config --get user.name) == 'Existing User' ]]
  [[ $(file_mode "$home/.zshrc.local") == 600 ]]
  [[ $(file_mode "$home/.zprofile.local") == 600 ]]
  [[ $(file_mode "$home/.gitconfig.local") == 600 ]]

  backup="$(find "$home/.dotfiles-backups" -mindepth 1 -maxdepth 1 -type d -print)"
  [[ -n $backup ]]
  [[ $(file_mode "$home/.dotfiles-backups") == 700 ]]
  [[ $(file_mode "$backup") == 700 ]]
  assert_file_text "$backup/.zshrc" 'old shell'
  assert_file_text "$backup/.config/nvim/init.lua" 'old nvim'

  assert_file_text "$home/.ssh/id_test" 'ssh-secret'
  assert_file_text "$home/.config/gh/hosts.yml" 'gh-secret'
  assert_file_text "$home/.aws/credentials" 'aws-secret'
  assert_file_text "$home/.gnupg/private-key" 'gpg-secret'
  assert_file_text "$home/.kube/config" 'kube-secret'
  assert_file_text "$home/.zshsecrets" 'shell-secret'
  assert_file_text "$home/.netrc" 'netrc-secret'
  assert_file_text "$home/.git-credentials" 'git-secret'
  assert_file_text "$home/.secrets/account" 'other-secret'
  pass '--migrate preserves local config, backups, and credential stores'

  local before after
  before="$(find "$home/.dotfiles-backups" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
  HOME="$home" "$INSTALL" --migrate >/dev/null
  after="$(find "$home/.dotfiles-backups" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
  [[ $before == "$after" ]]
  pass '--migrate is idempotent once installed'
}

test_migrate_refuses_local_collision() {
  local home
  home="$(new_home collision)"
  printf 'current shell\n' > "$home/.zshrc"
  printf 'existing local shell\n' > "$home/.zshrc.local"

  if HOME="$home" "$INSTALL" --migrate >/dev/null 2>&1; then
    return 1
  fi

  assert_file_text "$home/.zshrc" 'current shell'
  assert_file_text "$home/.zshrc.local" 'existing local shell'
  [[ ! -e $home/.dotfiles-backups ]]
  pass '--migrate aborts before changes when a local copy would collide'
}

test_migrate_refuses_recursive_local_copy() {
  local pair managed local_file home
  for pair in '.zshrc:.zshrc.local' '.zprofile:.zprofile.local' \
    '.gitconfig:.gitconfig.local'; do
    managed="${pair%%:*}"
    local_file="${pair#*:}"
    home="$(new_home "recursive-${managed#.}")"
    printf 'loads %s\n' "$local_file" > "$home/$managed"

    if HOME="$home" "$INSTALL" --migrate >/dev/null 2>&1; then
      return 1
    fi

    assert_file_text "$home/$managed" "loads $local_file"
    [[ ! -e $home/$local_file && ! -e $home/.dotfiles-backups ]]
  done
  pass '--migrate rejects configs that would recursively load themselves'
}

test_parent_obstruction_is_rejected_before_changes() {
  local home
  home="$(new_home parent-obstruction)"
  printf 'old shell\n' > "$home/.zshrc"
  printf 'blocks managed children\n' > "$home/.config"

  if HOME="$home" "$INSTALL" --apply >/dev/null 2>&1; then
    return 1
  fi

  assert_file_text "$home/.zshrc" 'old shell'
  assert_file_text "$home/.config" 'blocks managed children'
  [[ ! -e $home/.zprofile && ! -e $home/.dotfiles-backups ]]
  pass 'parent obstruction is rejected before a partial install'
}

test_symlinked_backup_root_is_rejected() {
  local home external
  home="$(new_home backup-root-link)"
  external="$TEST_ROOT/external-backups"
  mkdir -p "$external"
  chmod 755 "$external"
  ln -s "$external" "$home/.dotfiles-backups"
  printf 'old shell\n' > "$home/.zshrc"

  if HOME="$home" "$INSTALL" --migrate >/dev/null 2>&1; then
    return 1
  fi

  assert_file_text "$home/.zshrc" 'old shell'
  [[ -L $home/.dotfiles-backups && $(file_mode "$external") == 755 ]]
  [[ -z $(find "$external" -mindepth 1 -print -quit) ]]
  pass '--migrate rejects a symlinked backup root without following it'
}

test_migrate_rolls_back_link_failure() {
  local home fake_bin real_path
  home="$(new_home rollback)"
  fake_bin="$home/fake-bin"
  mkdir -p "$fake_bin"
  printf '#!/bin/sh\nprintf "unexpected path\\n" > "$3"\nexit 70\n' \
    > "$fake_bin/ln"
  chmod +x "$fake_bin/ln"

  printf 'old shell\n' > "$home/.zshrc"
  printf 'old profile\n' > "$home/.zprofile"
  printf '[user]\n\tname = Existing User\n' > "$home/.gitconfig"

  real_path="$PATH"
  if PATH="$fake_bin:$real_path" HOME="$home" \
    "$INSTALL" --migrate >/dev/null 2>&1; then
    return 1
  fi

  assert_file_text "$home/.zshrc" 'old shell'
  assert_file_text "$home/.zprofile" 'old profile'
  assert_file_text "$home/.gitconfig" $'[user]\n\tname = Existing User'
  [[ ! -e $home/.zshrc.local && ! -e $home/.zprofile.local \
    && ! -e $home/.gitconfig.local ]]
  assert_file_text \
    "$(find "$home/.dotfiles-backups" -path '*/.failed-links/.zshrc' -print)" \
    'unexpected path'
  pass '--migrate restores originals after a linking failure'
}

test_invalid_home_is_rejected() {
  if HOME=/ "$INSTALL" --migrate >/dev/null 2>&1; then
    return 1
  fi
  pass 'unsafe HOME is rejected before filesystem changes'
}

test_shell_starts_without_optional_tools() {
  local home empty_bin output
  home="$(new_home shell-minimal)"
  empty_bin="$home/empty-bin"
  mkdir -p "$empty_bin"

  output="$(PATH="$empty_bin" HOME="$home" /bin/zsh -dfc \
    "source '$REPO/.zshrc'" 2>&1)"
  [[ -z $output ]]
  [[ ! -e $home/.local/share/zinit ]]
  pass 'shell starts before Git, Zinit, or starship is installed'
}

test_default_is_read_only
test_apply_links_only_missing_targets
test_migrate_clean_home_needs_no_backup
test_migrate_preserves_and_backs_up
test_migrate_refuses_local_collision
test_migrate_refuses_recursive_local_copy
test_parent_obstruction_is_rejected_before_changes
test_symlinked_backup_root_is_rejected
test_migrate_rolls_back_link_failure
test_invalid_home_is_rejected
test_shell_starts_without_optional_tools

printf '1..%d\n' "$PASS_COUNT"
