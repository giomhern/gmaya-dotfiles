#!/usr/bin/env bash
#
# Safely link this repository's configuration into $HOME.
#
#   ./install.sh            read-only preflight (default)
#   ./install.sh --apply    link only targets that do not exist
#   ./install.sh --migrate  preserve conflicts, back them up, then link
#
# The installer never deletes a target. It never reads, moves, or links secret
# and account stores such as ~/.ssh, ~/.config/gh, ~/.aws, or ~/.zshsecrets.

set -Eeuo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE=check

usage() {
  printf 'Usage: %s [--check|--dry-run|--apply|--migrate]\n' "$0"
  printf '  --check, --dry-run  report without changing anything (default)\n'
  printf '  --apply             link missing targets; leave conflicts unchanged\n'
  printf '  --migrate           preserve and back up conflicts, then link them\n'
}

case "${1:-}" in
  ""|--check|--dry-run) ;;
  --apply) MODE=apply ;;
  --migrate) MODE=migrate ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    printf 'Unknown option: %s\n\n' "$1" >&2
    usage >&2
    exit 2
    ;;
esac

if (( $# > 1 )); then
  printf 'Only one option may be supplied.\n\n' >&2
  usage >&2
  exit 2
fi

if [[ -z ${HOME:-} || $HOME == / ]]; then
  printf 'Refusing to run with an empty HOME or HOME=/.\n' >&2
  exit 2
fi
if [[ ! -d $HOME ]]; then
  printf 'HOME is not a directory: %s\n' "$HOME" >&2
  exit 2
fi
HOME="$(cd "$HOME" && pwd -P)"

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

# Existing files whose contents must continue loading after migration. Keep the
# mapping in a function so the installer works with macOS's Bash 3.2.
LOCAL_COPY_SOURCES=(.zshrc .zprofile .gitconfig)

local_copy_for() {
  case "$1" in
    .zshrc) printf '.zshrc.local' ;;
    .zprofile) printf '.zprofile.local' ;;
    .gitconfig) printf '.gitconfig.local' ;;
    *) return 1 ;;
  esac
}

has_path() {
  [[ -e $1 || -L $1 ]]
}

is_installed() {
  local rel="$1"
  local dst="$HOME/$rel"
  [[ -L $dst && $(readlink "$dst") == "$REPO/$rel" ]]
}

validate_sources() {
  local rel
  for rel in "${FILES[@]}"; do
    if [[ ! -e $REPO/$rel ]]; then
      printf 'Repository source is missing: %s\n' "$REPO/$rel" >&2
      return 1
    fi
    case "$REPO" in
      "$HOME/$rel"|"$HOME/$rel/"*)
        printf 'Repository cannot be inside managed target: %s\n' \
          "$HOME/$rel" >&2
        return 1
        ;;
    esac
  done
}

validate_destination_parents() {
  local rel parent
  for rel in "${FILES[@]}"; do
    parent="$(dirname "$HOME/$rel")"
    while [[ $parent != "$HOME" ]] && ! has_path "$parent"; do
      parent="$(dirname "$parent")"
    done
    if [[ ! -d $parent ]]; then
      printf 'Cannot install %s: parent path is not a directory: %s\n' \
        "$rel" "$parent" >&2
      return 1
    fi
  done
}

preflight_migration() {
  local rel dst local_rel local_dst

  for rel in "${LOCAL_COPY_SOURCES[@]}"; do
    dst="$HOME/$rel"
    local_rel="$(local_copy_for "$rel")"
    local_dst="$HOME/$local_rel"

    if is_installed "$rel" || ! has_path "$dst"; then
      continue
    fi

    if [[ ! -f $dst ]]; then
      printf 'Cannot preserve %s: it is not a regular file.\n' "$dst" >&2
      return 1
    fi

    if has_path "$local_dst"; then
      printf 'Cannot migrate %s automatically because %s already exists.\n' \
        "$dst" "$local_dst" >&2
      printf 'Merge the current file into that local file, then rerun.\n' >&2
      return 1
    fi

    # Copying a config that already loads its destination local file would make
    # the new shared config recurse forever when it sources that copy.
    if grep -Fq "$local_rel" "$dst"; then
      printf 'Cannot migrate %s automatically because it references %s.\n' \
        "$dst" "$local_rel" >&2
      printf 'Extract its local settings manually, then rerun.\n' >&2
      return 1
    fi
  done
}

check_targets() {
  local rel dst
  validate_destination_parents
  printf 'Checking dotfiles from %s (read-only)\n\n' "$REPO"

  for rel in "${FILES[@]}"; do
    dst="$HOME/$rel"
    if is_installed "$rel"; then
      printf '  ok         %s\n' "$rel"
    elif has_path "$dst"; then
      printf '  CONFLICT   %s exists and would remain unchanged\n' "$rel"
    else
      printf '  would link %s\n' "$rel"
    fi
  done

  printf '\nCheck complete; nothing changed.\n'
}

link_missing() {
  local rel dst
  validate_destination_parents
  printf 'Linking missing dotfiles from %s\n\n' "$REPO"

  for rel in "${FILES[@]}"; do
    dst="$HOME/$rel"
    if is_installed "$rel"; then
      printf '  ok         %s\n' "$rel"
    elif has_path "$dst"; then
      printf '  CONFLICT   %s exists — left unchanged\n' "$rel"
    else
      mkdir -p "$(dirname "$dst")"
      ln -s "$REPO/$rel" "$dst"
      printf '  linked     %s\n' "$rel"
    fi
  done
}

migrate_targets() {
  local backup_root stamp backup rel dst local_rel local_dst
  local -a moved=() linked=() created_locals=()
  local moved_count=0 linked_count=0 created_local_count=0

  preflight_migration
  validate_destination_parents

  stamp="$(date +%Y%m%d-%H%M%S)"
  backup_root="$HOME/.dotfiles-backups"
  backup="$backup_root/$stamp"
  [[ ! -e $backup ]] || backup="$backup-$$"

  # If every target is installed already, migration is an idempotent no-op.
  local needs_work=0 has_conflicts=0
  for rel in "${FILES[@]}"; do
    is_installed "$rel" || needs_work=1
    if ! is_installed "$rel" && has_path "$HOME/$rel"; then
      has_conflicts=1
    fi
  done
  if (( ! needs_work )); then
    printf 'All managed targets already point to %s; nothing changed.\n' "$REPO"
    return
  fi

  # A clean home needs no rollback snapshot; this is equivalent to --apply.
  if (( ! has_conflicts )); then
    link_missing
    return
  fi

  if [[ -L $backup_root || ( -e $backup_root && ! -d $backup_root ) ]]; then
    printf 'Backup root must be a real directory: %s\n' "$backup_root" >&2
    return 1
  fi

  umask 077
  mkdir -p "$backup_root"
  chmod 700 "$backup_root"
  mkdir "$backup"
  chmod 700 "$backup"

  rollback() {
    local status=$?
    local item source target
    trap - ERR
    set +e
    printf '\nMigration failed; restoring original targets.\n' >&2

    mkdir -p "$backup/.failed-links"
    if (( linked_count )); then
      for item in "${linked[@]}"; do
        target="$HOME/$item"
        if is_installed "$item"; then
          mkdir -p "$backup/.failed-links/$(dirname "$item")"
          mv "$target" "$backup/.failed-links/$item"
        fi
      done
    fi

    if (( moved_count )); then
      for item in "${moved[@]}"; do
        source="$backup/$item"
        target="$HOME/$item"
        mkdir -p "$(dirname "$target")"
        if has_path "$target"; then
          mkdir -p "$backup/.failed-links/$(dirname "$item")"
          mv "$target" "$backup/.failed-links/$item"
        fi
        has_path "$source" && mv "$source" "$target"
      done
    fi

    if (( created_local_count )); then
      for item in "${created_locals[@]}"; do
        target="$HOME/$item"
        if has_path "$target"; then
          mkdir -p "$backup/.failed-local-copies/$(dirname "$item")"
          mv "$target" "$backup/.failed-local-copies/$item"
        fi
      done
    fi

    printf 'Original targets restored. Diagnostic files remain in %s\n' \
      "$backup" >&2
    exit "$status"
  }
  trap rollback ERR

  # Preserve shell and Git behavior outside the repository before moving any
  # managed target. -L follows an existing symlink and copies its contents.
  for rel in "${LOCAL_COPY_SOURCES[@]}"; do
    dst="$HOME/$rel"
    if is_installed "$rel" || ! has_path "$dst"; then
      continue
    fi
    local_rel="$(local_copy_for "$rel")"
    local_dst="$HOME/$local_rel"
    cp -npL "$dst" "$local_dst"
    if [[ ! -f $local_dst ]] || ! cmp -s "$dst" "$local_dst"; then
      printf 'Could not create an exact local copy at %s.\n' \
        "$local_dst" >&2
      return 1
    fi
    chmod 600 "$local_dst"
    created_locals+=("$local_rel")
    created_local_count=$((created_local_count + 1))
    printf '  preserved  %s -> ~/%s\n' "$rel" "$local_rel"
  done

  # Move every conflict into one timestamped rollback tree.
  for rel in "${FILES[@]}"; do
    dst="$HOME/$rel"
    if is_installed "$rel" || ! has_path "$dst"; then
      continue
    fi
    mkdir -p "$backup/$(dirname "$rel")"
    mv "$dst" "$backup/$rel"
    moved+=("$rel")
    moved_count=$((moved_count + 1))
    printf '  backed up  %s\n' "$rel"
  done

  # With conflicts safely moved, link every absent target.
  for rel in "${FILES[@]}"; do
    if is_installed "$rel"; then
      continue
    fi
    dst="$HOME/$rel"
    mkdir -p "$(dirname "$dst")"
    ln -s "$REPO/$rel" "$dst"
    linked+=("$rel")
    linked_count=$((linked_count + 1))
    printf '  linked     %s\n' "$rel"
  done

  trap - ERR
  printf '\nMigration complete. Rollback snapshot: %s\n' "$backup"
}

validate_sources

case "$MODE" in
  check) check_targets ;;
  apply) link_missing ;;
  migrate) migrate_targets ;;
esac

printf '\nSecrets and account credentials are outside the managed target list.\n'
printf '~/.zshsecrets remains local and is sourced only when present.\n'
