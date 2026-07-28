# dotfiles

Personal macOS setup: zsh, tmux, Neovim, and the Catppuccin Macchiato theming
that ties them together.

## Install

```sh
git clone https://github.com/gmayahern/gmaya-dotfiles.git ~/dotfiles-gmaya
cd ~/dotfiles-gmaya
./install.sh          # add --force to replace existing files (backed up first)
brew bundle           # restore the toolchain
```

`install.sh` **symlinks** rather than copies. The file in this repo is the file
the tool reads, so editing either path changes both and `git status` always
reflects reality. There is no sync step to forget.

## What's here

| Path | |
|---|---|
| `.zshrc` | Shell config, sectioned and indexed at the top |
| `.zshenv`, `.zprofile` | Login/env stubs |
| `.tmux.conf` | tmux + tpm plugins |
| `.gitconfig` | Git identity, colors, aliases |
| `.config/nvim/` | Neovim config — `init.lua`, `lsp/`, `lua/core/` |
| `.config/starship.toml` | Prompt |
| `.config/ghostty/` | Terminal |
| `.config/btop/` | System monitor |
| `Brewfile` | Everything installed via Homebrew |

## Notes

**Java is pinned to 25.** `JAVA_HOME` targets `openjdk@25` explicitly, because
the unversioned Homebrew `openjdk` formula tracks the newest release (26 at time
of writing). `$JAVA_HOME/bin` leads `$PATH`, so nvim's `jdtls` and the shell
always agree on a version. Bump both by editing the one `JAVA_HOME` line.

**Navigation crosses the tmux/nvim boundary.** `Ctrl` + arrow keys move between
Neovim splits and tmux panes with the same keystroke — tmux checks whether the
pane is running nvim and either forwards the key or moves the pane. Ctrl-hjkl is
deliberately avoided: `Ctrl-j`/`Ctrl-k` belong to multicursor, and `Alt-j`/`Alt-k`
move lines.

**`Ctrl-t` belongs to tmux**, which binds it at the root key table for the popup
session. It never reaches zsh, so fzf's Ctrl-T file widget is unreachable inside
tmux. `Ctrl-r` and `Alt-c` are unaffected.

**Neovim plugins** are managed by the built-in `vim.pack` and install into
`~/.local/share/nvim`. Only `nvim-pack-lock.json` is tracked. First launch
bootstraps them and compiles treesitter parsers.

**tmux plugins** need `prefix + I` (capital i) once after a fresh clone. Prefix
is `Ctrl-a`.

## Secrets

Not in this repo, and gitignored so they can't be added by accident. `.zshrc`
reads them if present and stays quiet if not:

- `~/.secrets/github.com` — a token, read into `GITHUB_TOKEN`
- `~/.zshsecrets` — sourced if it exists

## Credit

The Neovim config and several shell helpers originate from
[ricoberger/dotfiles](https://github.com/ricoberger/dotfiles), since diverged.
