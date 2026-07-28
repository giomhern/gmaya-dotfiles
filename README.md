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

Three layers, three modifiers, almost no collisions:

- **Ghostty** owns `Cmd`. It is the only thing with a real window.
- **tmux** owns `Ctrl-a` (the prefix) and a couple of no-prefix keys.
- **Neovim** owns everything else. Leader is `Space`.

`Ctrl` + arrows is the one key that crosses a boundary, deliberately — see
*Navigation crosses the tmux/nvim boundary* below.

### A day at the keyboard

**Start.** `ts` attaches the `main` session, or creates it. You almost never
start a second one; you make windows instead. tmux-continuum has been
autosaving every 15 minutes, so a reboot costs you nothing — panes, layouts and
working directories come back on their own.

**One window per repo.** `prefix + c` opens a window in the current directory
and it names itself after that directory, so the status bar reads `payments-api`
rather than `zsh`. `prefix + 1…9` jumps straight to one. If you have more than
about six open you have too many; `prefix + &` closes one.

**Split for the job, not for the aesthetic.** `prefix + |` puts a pane to the
right, `prefix + -` below. The useful shape for a service is editor left, and
right split in two for a log tail and a shell. `prefix + z` zooms the focused
pane to fill the window and again to restore it — reach for it constantly, it
is faster than resizing. When you do need to resize, `prefix + Shift`+arrows
repeats, so hold `Shift` and tap.

**Move without thinking.** `Ctrl` + arrows, no prefix, crosses nvim splits and
tmux panes identically. This is the keystroke you press most; it is worth the
machinery behind it.

**Inside nvim, navigate by meaning, not by path.**

| | |
|---|---|
| `gW` | any symbol in the workspace — **start here in a big repo** |
| `gO` | symbols in this file |
| `gd` / `grr` / `gri` | definition / references / implementations |
| `<leader>ff` | find a file by path |
| `<leader>ss` | grep the project |
| `<leader>sw` | grep the word under the cursor |
| `<leader>fb` / `<leader>fr` | open buffers / recent files |
| `<leader>ee` | file explorer, only when you genuinely want to browse |
| `<leader>d` | diagnostics for the buffer into the location list |

The ordering matters. `gW` beats everything else in a Java or Go codebase
because jdtls and gopls index the whole workspace — type `PaymentControl` and
land on the class, no idea where it lives. Fall back to `<leader>ff` when you
know the filename, `<leader>ss` when you only know a string. `<leader>ee` is
last resort: a directory tree is the slowest way to find anything you can name.

**Edit.** `Ctrl-n` adds a cursor at the next occurrence of the word under the
cursor, `Ctrl-a` at all of them — the fastest rename when it is textual rather
than semantic. Use `grn` instead when it is a real symbol, so the LSP fixes
imports and other files too. `Alt-j` / `Alt-k` move the current line or
selection. `grf` formats.

**Review before committing.** `]c` and `[c` walk hunks, `<leader>gss` stages
one, `<leader>gsr` resets one, `<leader>gsp` previews. `<leader>gsb` blames the
line. The `<leader>gf*` family opens fzf pickers over branches, status, stashes
and log.

**Scratch work goes in the popup.** `Alt-t` floats a shell over whatever you
are doing, in the same directory. Run the one-off `docker compose logs`, the
`mvn dependency:tree`, the `kubectl get pods`; `Alt-t` again dismisses it. Your
pane layout is never disturbed for a throwaway command.

**Copy something out.** `prefix + [` enters copy mode with vi keys — `v`
selects, `Ctrl-v` for a block, `y` copies and exits, `Esc` leaves. Mouse drag
also copies and no longer snaps the view back to the prompt.

### The rest of tmux

| | |
|---|---|
| `prefix` + `,` | rename this window by hand (overrides the auto-name) |
| `prefix` + `n` / `p` | next / previous window — repeatable |
| `prefix` + `&` / `x` | kill the window / the pane |
| `prefix` + `d` | detach; everything keeps running |
| `prefix` + `r` | reload `~/.tmux.conf` |
| `prefix` + `I` | install plugins — once, after a fresh clone |
| `prefix` + `Ctrl-s` / `Ctrl-r` | save / restore the session by hand |

Windows and panes are both 1-indexed, and windows renumber themselves when one
closes, so `prefix + 3` always means the third window you can see.

## Neovim reference

Leader is `Space`. Mode is noted only where it isn't normal.

### Moving around a codebase

| | |
|---|---|
| `gW` | workspace symbol — any class, func or method by name |
| `gO` | symbols in this file |
| `gd` / `gD` | definition / declaration |
| `grr` | references |
| `gri` / `grt` | implementations / type definition |
| `K` | hover docs |
| `Ctrl-s` | signature help (also insert mode) |
| `<leader>ff` / `fb` / `fr` | files / open buffers / recent files |
| `<leader>ee` | explorer at this file's directory |
| `<leader>ew` | write, no autocommands, creating parent dirs |
| `Ctrl-o` / `Ctrl-i` | back / forward in the jump list |

### Searching

| | |
|---|---|
| `<leader>ss` | grep the project |
| `<leader>sw` | grep the word under the cursor (or selection, in visual) |
| `<leader>st` | grep TODO / FIXME / HACK / WARN tags |
| `:find <name>` | fd-backed fuzzy path completion |
| `:grep <pat>` | ripgrep straight into the quickfix list |

### Editing

| | |
|---|---|
| `grn` | LSP rename — use this for symbols, it fixes other files |
| `gra` | code action (imports, generate, quick fix) |
| `grf` | format the buffer |
| `Ctrl-n` | add a cursor at the next match of the word under the cursor |
| `Ctrl-a` | add cursors at every match |
| `Ctrl-j` / `Ctrl-k` | add a cursor on the line below / above |
| `Ctrl-m` (visual) | add a cursor on each selected match |
| `Alt-j` / `Alt-k` | move line or selection down / up (n, i, x) |
| `<` / `>` (visual) | indent, keeping the selection |
| `<leader>rr` / `rw` | substitute in this buffer, blank / word under cursor |
| `<leader>rR` / `rW` | the same across every quickfix file, then save |
| `Esc` | clear search highlight |

`grn` versus `Ctrl-n` is the distinction worth internalising: `grn` asks jdtls or
gopls to rename the *symbol* everywhere including imports; `Ctrl-n` is multiple
cursors over *text* in this buffer. Reach for `grn` on anything the LSP knows.

### Completion

| | |
|---|---|
| `Ctrl-Space` (insert) | trigger completion |
| `Ctrl-Enter` (insert) | accept the Copilot inline suggestion |
| `Ctrl-Right` (insert) | accept the suggestion one word at a time |
| `Ctrl-Up` / `Ctrl-Down` (insert) | cycle inline suggestions |
| `Tab` / `Shift-Tab` (insert) | jump between snippet placeholders |

### Diagnostics and quickfix

| | |
|---|---|
| `]d` / `[d` | next / previous diagnostic |
| `]D` / `[D` | last / first diagnostic in the buffer |
| `Ctrl-w` `d` | show the diagnostic under the cursor |
| `<leader>d` / `<leader>D` | all diagnostics into the location / quickfix list |
| `]q` / `[q` | next / previous quickfix item |
| `dd`, `d` (visual) | delete entries from inside the quickfix window |
| `grh` | toggle inlay hints |

The quickfix list is the spine of the whole config — grep, diagnostics, LSP
references and git hunks all land there, and `<leader>rR` rewrites across every
file in it. Build a list, then act on it.

### Git

| | |
|---|---|
| `]c` / `[c` | next / previous hunk |
| `<leader>gss` / `gsr` | stage / reset the hunk (works on a visual range) |
| `<leader>gsS` / `gsR` | stage / reset the whole buffer |
| `<leader>gsu` | undo the last stage |
| `<leader>gsp` | preview the hunk inline |
| `<leader>gsb` | blame this line |
| `<leader>gsd` / `gsD` | diff this file / the whole tree |
| `<leader>gsq` | every hunk into the quickfix list |
| `<leader>gst` | toggle hunk line highlighting |
| `<leader>gff` / `gfs` | fzf over tracked files / working tree status |
| `<leader>gfb` / `gfz` | branches / stashes |
| `<leader>gfd` | changed files |
| `<leader>gfl` / `gfL` | log for this file / the repo |
| `<leader>gfm` | find merge conflicts, into the quickfix list |

On a PR the `prlsp` client adds `<leader>ghc` to comment (works on a visual
range), `<leader>ghr` to reply, `<leader>ghs` to show the thread, `<leader>ghu`
to refresh.

### Explorer buffers

Directory buffers open with `<leader>ee` or by editing a path. `<CR>` opens, `-`
goes up.

| | |
|---|---|
| `Tab` | mark a file (works over a visual range) |
| `Esc` | clear all marks |
| `n` / `d` / `r` | create / delete / rename |
| `m` / `c` | move / copy the marked files here |
| `Ctrl-s` / `Ctrl-v` / `Ctrl-t` | open in split / vsplit / tab |
| `Ctrl-q` | marked files into the quickfix list |
| `s` | grep this directory |
| `=` | diff two marked files |

### Inside any fzf picker

| | |
|---|---|
| `Enter` | open |
| `Ctrl-s` / `Ctrl-v` / `Ctrl-t` | split / vsplit / tab |
| `Ctrl-q` | send all matches to the quickfix list |
| `Tab` | multi-select (file and grep pickers; not branches, log or stash) |
| `Ctrl-p` | toggle the preview |
| `Ctrl-d` / `Ctrl-u` | half page down / up in the list |
| `Ctrl-f` / `Ctrl-b` | half page down / up in the preview |
| `Ctrl-x` | delete the buffer (buffer picker only) |

`Ctrl-q` is the one people forget. Grep for something, `Ctrl-q` the lot into
quickfix, then `<leader>rR` to rewrite every match across every file.

### Windows and misc

| | |
|---|---|
| `Ctrl` + arrows | move between splits *and* tmux panes |
| `Shift` + arrows | resize the split |
| `<leader>y` | copy a reference to this file — menu of filename, relative path, absolute path, GitHub URL, or the diagnostic under the cursor |

`<leader>y` `→` *Git Url* is the fastest way to paste a permalink into Slack or
a PR; it takes the visual selection into account and produces a line range.

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
