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

Nothing crosses a boundary, which means `prefix` + arrows moves tmux panes and
`Ctrl-w` moves nvim splits — see *macOS owns Ctrl+arrows* below for why there is
no single key for both.

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

**Move between panes** with `prefix` + arrows. It repeats, so `Ctrl-a` once then
arrow, arrow, arrow walks the layout. Inside nvim, splits are `Ctrl-w` + `h`/`j`
/`k`/`l` (or `Ctrl-w` + arrows). Two different keys for two different things —
see *macOS owns Ctrl+arrows*.

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
| `prefix` + `x` / `&` | kill the pane / the window — `y` confirms, `Esc` backs out |
| `prefix` + `d` | detach; everything keeps running |
| `prefix` + `r` | reload `~/.tmux.conf` |
| `prefix` + `I` | install plugins — once, after a fresh clone |
| `prefix` + `Ctrl-s` / `Ctrl-r` | save / restore the session by hand |

Windows and panes are both 1-indexed, and windows renumber themselves when one
closes, so `prefix + 3` always means the third window you can see.

## Vim fundamentals

Plain Vim, not this config — but you need it before any of the rest is useful.
Where this setup changes a default, it says so.

### Modes

You start in **normal** mode, where letters are commands, not text. `Esc` always
returns there. The rest of the table assumes normal mode.

| | |
|---|---|
| `i` / `a` | insert **before** / **after** the cursor |
| `I` / `A` | insert at the first non-blank / at end of line |
| `o` / `O` | open a new line below / above and insert |
| `v` / `V` | visual character / whole line |
| `Ctrl-v` | visual **block** — column selection |
| `:` | command line |
| `Esc` | back to normal (here it also clears search highlight) |

`I` and `A` are the ones worth drilling. "Jump to the start/end of this line and
start typing" is a single keystroke, not `0` then `i`.

### Moving

| | |
|---|---|
| `h` `j` `k` `l` | left, down, up, right (arrows work too) |
| `w` / `b` | forward / back one word |
| `e` | end of the current word |
| `W` `B` `E` | same, but whitespace-separated — skips punctuation |
| `0` / `^` / `$` | start of line / first non-blank / end of line |
| `f<char>` / `F<char>` | jump to next / previous `<char>` on this line |
| `t<char>` / `T<char>` | jump just before / after it |
| `;` / `,` | repeat the last `f`/`t` forward / backward |
| `%` | jump to the matching bracket |
| `{` / `}` | previous / next blank line — paragraph hops |
| `Ctrl-d` / `Ctrl-u` | half a screen down / up |
| `Ctrl-f` / `Ctrl-b` | full page down / up |
| `H` / `M` / `L` | top / middle / bottom of the visible screen |
| `zz` / `zt` / `zb` | scroll so the cursor sits centre / top / bottom |

**A caveat specific to this config:** `j`, `k` and the up/down arrows are mapped
to `gj`/`gk`, so they move by *visible* line rather than by real line. On a long
wrapped line they step within it. Give a count (`5j`) and you get the normal
behaviour back.

### Jumping to a line

| | |
|---|---|
| `gg` / `G` | first / last line of the file |
| `42G` or `:42` | go to line 42 |
| `Ctrl-g` | show where you are |
| `Ctrl-o` / `Ctrl-i` | back / forward through the jump list |
| ``` `` ``` | back to where you last jumped from |

`Ctrl-o` is the undo button for navigation. Followed a definition three files
deep? `Ctrl-o` three times walks you back out.

### Searching in a file

| | |
|---|---|
| `/text` then `Enter` | search forward |
| `?text` | search backward |
| `n` / `N` | next / previous match |
| `*` / `#` | search for the word under the cursor, forward / back |
| `:noh` | clear the highlight (or just press `Esc` here) |

Search is case-sensitive unless the pattern is all lowercase. `\c` anywhere in
the pattern forces case-insensitive: `/todo\c`.

For searching *across* files, use `<leader>ss` — see [Searching](#searching).

### Changing text

Operators combine with the motions above: `d` + `w` deletes a word, `c` + `$`
changes to end of line. That composition is the whole language.

| | |
|---|---|
| `x` / `X` | delete the character under / before the cursor |
| `dd` / `cc` | delete / change the whole line |
| `D` / `C` | delete / change to end of line |
| `dw` / `cw` | delete / change to the next word |
| `d$` `d0` `dG` `dgg` | delete to end of line / start / end of file / start |
| `r<char>` | replace one character, staying in normal mode |
| `s` | delete the character and insert |
| `J` | join this line with the next |
| `~` | toggle the case of one character |
| `.` | **repeat the last change** |
| `u` / `Ctrl-r` | undo / redo |

`.` is the highest-value key in Vim. Make a small edit, `n` to the next match,
`.` to repeat it. Most of what people use multiple cursors for is `.` in a loop.

**A second caveat:** Vim increments the number under the cursor with `Ctrl-a`
and decrements with `Ctrl-x`. Here `Ctrl-a` belongs to multicursor instead, so
only the decrement half survives. Use `:s` or multicursor for bulk number
edits.

### Text objects

Operators also take objects: `i` for "inner", `a` for "around" (includes the
delimiters).

| | |
|---|---|
| `diw` / `ciw` | delete / change the word under the cursor |
| `ci"` `ci'` `ci(` `ci[` `ci{` | change inside the quotes / brackets |
| `ca(` | change the brackets *and* their contents |
| `dit` / `cit` | delete / change inside an HTML or XML tag |
| `dap` | delete a whole paragraph |

`ci"` with the cursor anywhere inside a string replaces its contents. `ciw` with
the cursor anywhere in a word replaces the word. Neither needs you to position
precisely first.

### Copy and paste

| | |
|---|---|
| `yy` | yank (copy) the line |
| `yw` / `y$` | yank a word / to end of line |
| `p` / `P` | paste after / before the cursor |
| `dd` then `p` | move a line |
| `"+y` / `"+p` | yank to / paste from the **system** clipboard |

Vim's registers are separate from the macOS clipboard. `"+` is the bridge. In
visual mode, `"+y` copies the selection out to other apps.

### Visual mode

Select first, then act. `v` then a motion, then an operator.

| | |
|---|---|
| `viw` | select the word |
| `V` then `j` `j` | select three lines |
| `d` / `y` / `c` | delete / yank / change the selection |
| `<` / `>` | indent left / right — here the selection stays put |
| `Ctrl-v` then `I` then `Esc` | insert the same text on every selected line |

### Counts

Almost anything takes a number prefix: `3dd` deletes three lines, `5j` moves
down five, `2ci"` — the grammar is `count` + `operator` + `motion`.

### Files, buffers, splits

| | |
|---|---|
| `:w` / `:q` / `:wq` | write / quit / both |
| `:q!` | quit, discarding changes |
| `:e <file>` | open a file |
| `:bn` / `:bp` / `:bd` | next / previous / close buffer |
| `Ctrl-w` `s` / `v` | split horizontally / vertically |
| `Ctrl-w` + `h` `j` `k` `l` | move between splits |
| `Ctrl-w` `o` | close every split but this one |
| `Ctrl-w` `q` | close this split |

**One gotcha:** inside a directory buffer (the file explorer), `n`, `d`, `r`,
`c`, `m` and `s` are rebound to create, delete, rename, copy, move and grep.
They are file operations there, not motions. See
[Explorer buffers](#explorer-buffers).

## Neovim reference

Everything below is specific to this config. Leader is `Space`. Mode is noted
only where it isn't normal.

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
| `Ctrl-w` + `h`/`j`/`k`/`l` | move between splits (arrows work too) |
| `Ctrl-w` `s` / `v` | split horizontally / vertically |
| `Ctrl-w` `o` | close every split but this one |
| `Shift` + arrows | resize the split |
| `<leader>y` | copy a reference to this file — menu of filename, relative path, absolute path, GitHub URL, or the diagnostic under the cursor |

`<leader>y` `→` *Git Url* is the fastest way to paste a permalink into Slack or
a PR; it takes the visual selection into account and produces a line range.

## Notes

**Java is pinned to 25.** `JAVA_HOME` targets `openjdk@25` explicitly, because
the unversioned Homebrew `openjdk` formula tracks the newest release (26 at time
of writing). `$JAVA_HOME/bin` leads `$PATH`, so nvim's `jdtls` and the shell
always agree on a version. Bump both by editing the one `JAVA_HOME` line.

**macOS owns Ctrl+arrows.** This config used to bind them at the tmux root table
to cross nvim splits and tmux panes with one keystroke: tmux inspected the
pane's process list and either forwarded the key to nvim or moved the pane
itself. It cannot work here. The macOS window server claims all four before any
terminal sees them — `Ctrl-←`/`Ctrl-→` switch Spaces, `Ctrl-↑` is Mission
Control, `Ctrl-↓` is Application Windows — and pressing one moved the whole
desktop instead. The bindings and the `vim-tmux-navigator` plugin behind them
are gone; panes are `prefix` + arrows, splits are `Ctrl-w`.

Disabling the four shortcuts in *System Settings > Keyboard > Keyboard Shortcuts
> Mission Control* would free the keys if the unified navigation is ever worth
having back.

**`Alt-t` toggles a floating scratch session** (`popup`), opened in the current
pane's directory. Press it again from inside to dismiss. It used to be `Ctrl-t`,
which was a bad choice twice over: root-table bindings never reach the pane, so
it swallowed both fzf's Ctrl-T file widget and nvim's explorer open-in-new-tab.
The popup command runs with `TMUX=` unset — tmux refuses to attach a session
from inside an existing client otherwise, so the old binding just flashed and
closed.

**Kill confirmations are a centred menu**, not tmux's built-in
`confirm-before`, which takes over the status line and leaves the cursor
blinking next to the window name. `prefix + x` and `prefix + &` open a small
themed box in the middle of the screen; `y` still confirms. The `menu-*` styles
near the top of `.tmux.conf` spell out the macchiato hexes rather than using
`#{@thm_*}`, because those only exist once catppuccin has loaded and tpm loads
it asynchronously from the last line of the file.

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
