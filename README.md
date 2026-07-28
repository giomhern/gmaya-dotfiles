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
| `.zprofile` | Login shell — sets up the Homebrew environment |
| `.tmux.conf` | tmux + tpm plugins |
| `.gitconfig` | Git identity, colors, aliases |
| `.config/nvim/` | Neovim config — `init.lua`, `lsp/`, `lua/core/` |
| `.config/starship.toml` | Prompt |
| `.config/ghostty/` | Terminal |
| `.config/btop/` | System monitor |
| `Brewfile` | Everything installed via Homebrew |

## Keys

tmux prefix is `Ctrl-a`.

| tmux | |
|---|---|
| `prefix` + `\|` / `-` | split right / down, in the current directory |
| `prefix` + `c` | new window, in the current directory |
| `Ctrl` + arrows | move between panes *and* nvim splits (no prefix) |
| `prefix` + `Shift`+arrows | resize the pane — repeatable, keep tapping |
| `prefix` + `z` | zoom / unzoom the pane |
| `prefix` + `n` / `p` | next / previous window — repeatable |
| `prefix` + `1`…`9` | jump to window (windows and panes are 1-indexed) |
| `Alt-t` | toggle the floating scratch session (no prefix) |
| `prefix` + `[` | copy mode — `v` select, `Ctrl-v` block, `y` copy, `Esc` out |
| `prefix` + `r` | reload `~/.tmux.conf` |
| `prefix` + `I` | install plugins (once, after a fresh clone) |

| nvim | |
|---|---|
| `<leader>ff` / `fb` / `fr` | find files / buffers / recent |
| `<leader>ss` / `sw` | grep project / word under cursor |
| `<leader>ee` | file explorer at the current file's directory |
| `gd` / `grr` / `gri` | definition / references / implementations |
| `gO` / `gW` | symbols in this file / anywhere in the workspace |

`gW` is the one to reach for in a large Java or Go repo — jdtls and gopls index
the whole workspace, so jumping by symbol name beats walking a directory tree.
`<leader>ff` for paths, `<leader>ss` for content, `<leader>ee` only when you
actually want to *browse*.

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

**`Alt-t` toggles a floating scratch session** (`popup`), opened in the current
pane's directory. Press it again from inside to dismiss. It used to be `Ctrl-t`,
which was a bad choice twice over: root-table bindings never reach the pane, so
it swallowed both fzf's Ctrl-T file widget and nvim's explorer open-in-new-tab.
The popup command runs with `TMUX=` unset — tmux refuses to attach a session
from inside an existing client otherwise, so the old binding just flashed and
closed.

**Windows name themselves** after the directory of the active pane
(`automatic-rename-format`). The previous `after-new-window` hook opened a
blocking rename prompt on every single window, including the ones tmux-resurrect
creates while restoring. `prefix + ,` still renames by hand.

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
