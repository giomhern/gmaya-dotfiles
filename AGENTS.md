# Dotfiles Safety Contract

This repository manages interactive configuration for a laptop. Treat existing
home-directory state as user data. A successful setup preserves account
identity, credentials, machine-specific settings, and a complete rollback path.

## Non-negotiable rules

- Never add a force-overwrite option to `install.sh`.
- Never delete an existing managed target. `--migrate` must move conflicts into
  one timestamped backup tree before creating symlinks.
- Keep the backup root and each migration snapshot private (`0700`). Local
  shell/profile/Git copies must be private (`0600`) because an existing config
  can contain credentials even when it should not.
- Installer and migration tooling must never manage, move, copy, source,
  inspect, or print credential contents from `~/.ssh`, `~/.gnupg`,
  `~/.config/gh`, `~/.aws`, `~/.kube`, `~/.netrc`, `~/.git-credentials`,
  `~/.zshsecrets`, or `~/.secrets`. The interactive shell may source
  `~/.zshsecrets` at runtime.
- Never commit real identity/email values, signing keys, credential helpers,
  account names, employer profiles, tokens, private keys, or absolute user-home
  paths. Clearly fake values are allowed in `.example` files.
- Keep Git identity and account settings in `~/.gitconfig.local`. The tracked
  `.gitconfig` includes it last so local choices win.
- Keep machine shell settings in `~/.zshrc.local` and login-shell settings in
  `~/.zprofile.local`. These files stay outside Git.
- In the `--work` profile, never manage, inspect, copy, move, back up, or link
  `~/.zshrc`, `~/.zprofile`, or `~/.gitconfig`. The optional work shell fragment
  must remain a separate, manually sourced file under `~/.config/gmaya`.
- Keep machine tmux styling in `~/.tmux.conf.local`. The shared config may
  source it, but installation and theme tooling must not create or rewrite it.
- Do not run `brew bundle`, uninstall packages, change Homebrew ownership, or
  authenticate an account as part of a dotfiles migration unless the user asks.
- Do not rewrite repository history to remove old identifiers without explicit
  authorization. Report historical residue separately from the current tree.

## Installation workflow

1. Clone into its own directory. Do not clone over an existing dotfiles tree.
2. Run `./install.sh` with no arguments. This is a read-only preflight.
3. If every target is absent, run `./install.sh --apply`.
4. If conflicts exist and the user wants this repository's UI, editor, shell,
   or keybindings to become active, run `./install.sh --migrate`.
5. If migration refuses because a local file already exists, stop. Compare and
   merge the two local files manually; do not choose one automatically.
   The same rule applies when an existing config already references the local
   filename, because copying it would create recursive loading.
6. Run `./install.sh` again and require every managed path to report `ok`.
7. Let Neovim bootstrap lazy.nvim on first launch. Plugin state belongs under
   `~/.local/share/nvim/lazy`, outside this repository. tmux plugin state
   belongs under `~/.tmux/plugins`.

Keep Neovim plugin declarations and configuration under
`.config/nvim/lua/plugins/`, grouped by feature. Keep `init.lua` for editor-wide
options, autocmds, commands, LSP, diagnostics, and general keymaps.

On a managed work laptop, use `./install.sh --work` for preflight and combine
`--work` with `--apply` or `--migrate`. Verify the three company configuration
paths remain byte-for-byte and mode-for-mode unchanged. Source
`~/.config/gmaya/work-shell.zsh` manually only after company initialization.

`--apply` creates links only for absent targets. It leaves every conflict
untouched. `--migrate` preserves `.zshrc`, `.zprofile`, and `.gitconfig` as local
files, moves every conflict into `~/.dotfiles-backups/<timestamp>/`, and rolls
back original targets if linking fails. Re-running either mode is idempotent.

## Managed and protected boundaries

The managed target list is defined once in `install.sh` and currently contains:

- `~/.zshrc`, `~/.zprofile`, `~/.tmux.conf`, and `~/.gitconfig`
- `~/.config/starship.toml`
- `~/.config/ghostty`, `~/.config/nvim`, and `~/.config/btop`

The work profile excludes `.zshrc`, `.zprofile`, and `.gitconfig`, and adds
`~/.config/gmaya/work-shell.zsh`. It must never weaken the protected-path rules.

Adding a target requires updating the installer, README, and tests together.
Never add a protected credential path or a parent directory such as `~/.config`.

## Required validation

Run these checks after changing installation or local-include behavior:

```sh
bash -n install.sh theme.sh tests/install_test.sh tests/theme_test.sh
zsh -n .zshrc .zprofile
tests/install_test.sh
tests/theme_test.sh
tests/nvim_workflow_test.sh
git diff --check
```

Run `tests/theme_test.sh` after changing palettes or theme integration. Theme
changes must go through `theme.sh` so Ghostty, Neovim, tmux, Starship, both fzf
interfaces, bat, and btop stay in sync. Keep `.theme` consistent with the
generated application settings.

The test suite must cover read-only default behavior, conflict-safe apply,
backup migration, exact local-file preservation, credential-store preservation,
private permissions, idempotency, local collision/self-include refusal, rollback
after failure, parent-path obstruction, unsafe `HOME` rejection, work-profile
protection in every mode, and work-shell composition after company startup.
Tests must use temporary home directories and must never point a mutating mode
at the real home directory. The shared shell must also start when optional tools
such as Git, Zinit, and starship are unavailable.

The Neovim workflow test must cover directory startup without an unnamed
buffer, next-buffer selection, last-buffer fallback to full-screen Neo-tree,
explorer focus/toggle behavior, and file-type-aware preview dispatch without
launching real GUI apps. Neovim must not change tmux's configured status
position. It must also preserve the 80-column code ruler and soft wrapping,
plus the 160-column Markdown ruler and prose wrapping. Require an installed
Bash parser and non-empty Treesitter highlight queries for shell buffers.

Before committing, search the current tree for employer names, email addresses,
tokens, private-key headers, cloud profiles, and absolute `/Users/...` paths.
Do not print a suspected secret value; report only its file and category.

## Rollback

Rollback snapshots mirror paths relative to `$HOME`. To restore, first move the
dotfiles symlink out of the way, then move the corresponding item from the
snapshot back to its original location. Preserve local files unless the user
explicitly chooses to remove them. Never automate rollback with broad recursive
deletion or an unvalidated backup path.
