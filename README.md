# dotfiles

Personal macOS setup: zsh, tmux, Neovim, and synchronized terminal theming
that ties them together.

## Contents

- [Install](#install) · [What's here](#whats-here)
- [Keys](#keys) — [a day at the keyboard](#a-day-at-the-keyboard) ·
  [the rest of tmux](#the-rest-of-tmux)
- [Vim fundamentals](#vim-fundamentals) — [modes](#modes) ·
  [moving](#moving) · [jumping to a line](#jumping-to-a-line) ·
  [searching in a file](#searching-in-a-file) ·
  [changing text](#changing-text) · [text objects](#text-objects) ·
  [commenting](#commenting) · [copy and paste](#copy-and-paste) ·
  [visual mode](#visual-mode) · [counts](#counts) ·
  [files, buffers, splits](#files-buffers-splits)
- [Neovim reference](#neovim-reference) —
  [moving around a codebase](#moving-around-a-codebase) ·
  [searching](#searching) · [editing](#editing) ·
  [completion](#completion) ·
  [diagnostics and quickfix](#diagnostics-and-quickfix) · [git](#git) ·
  [file explorers](#file-explorers) ·
  [buffer tabs](#buffer-tabs) ·
  [fzf pickers](#inside-any-fzf-picker) ·
  [windows and misc](#windows-and-misc)
- [Notes](#notes) · [Secrets](#secrets) · [Credit](#credit)

New to Vim? Start with [Vim fundamentals](#vim-fundamentals). Everything under
[Neovim reference](#neovim-reference) is specific to this config.

## Install

```sh
git clone https://github.com/giomhern/gmaya-dotfiles.git ~/gmaya-dotfiles
cd ~/gmaya-dotfiles
./install.sh          # read-only preflight; reports conflicts and missing paths
# Choose one after reviewing the preflight:
./install.sh --apply   # link missing paths and leave conflicts active
./install.sh --migrate # preserve conflicts, then make this setup authoritative
# Optional: review the Brewfile first, then install its tools with brew bundle
```

`install.sh` **symlinks** rather than copies. The file in this repo is the file
the tool reads, so editing either path changes both and `git status` always
reflects reality. There is no sync step to forget.

The default run changes nothing. `--apply` links only paths that are absent;
every file, directory, or symlink already in `$HOME` is reported as a conflict
and left untouched. Review the conflicts before choosing `--migrate`.

`--migrate` is the explicit path for making this setup authoritative on a
laptop that already has configuration. Before linking, it copies the existing
shell, login-shell, and Git configuration to `~/.zshrc.local`,
`~/.zprofile.local`, and `~/.gitconfig.local`. It moves all conflicting managed
targets into `~/.dotfiles-backups/<timestamp>/`. If a local file already exists,
the preflight aborts before changing anything so two configurations are never
silently merged. A linking failure restores the original targets.

Credential and account stores—including `~/.ssh`, `~/.gnupg`, `~/.config/gh`,
`~/.aws`, `~/.kube`, `~/.netrc`, `~/.git-credentials`, `~/.zshsecrets`, and
`~/.secrets`—are outside the managed target list. The installer neither reads
nor modifies them.

To try this Neovim setup without replacing an existing `~/.config/nvim`, link
it under another app name and launch it explicitly:

```sh
ln -s "$PWD/.config/nvim" ~/.config/nvim-gmaya
NVIM_APPNAME=nvim-gmaya nvim
```

Git identity and account settings live in `~/.gitconfig.local`, which is
included by the tracked `.gitconfig` but never committed. Start from
`.gitconfig.local.example` on a new laptop. Machine-specific shell settings
belong in `~/.zshrc.local` and `~/.zprofile.local`; the matching `.example`
files contain examples.

## What's here

| Path | |
|---|---|
| `.zshrc` | Shell config, sectioned and indexed at the top |
| `.zprofile` | Login shell — sets up the Homebrew environment |
| `.tmux.conf` | tmux + tpm plugins |
| `.gitconfig` | Shared Git behavior; identity stays local |
| `.config/nvim/` | Neovim config — `init.lua`, `lsp/`, `lua/core/` |
| `.config/starship.toml` | Prompt |
| `.config/ghostty/` | Terminal |
| `.config/btop/` | System monitor |
| `.theme`, `theme.sh` | Shared visual theme and synchronized switcher |
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
start a second one; you make windows instead. Save and restore intentionally
with `prefix + Ctrl-s` and `prefix + Ctrl-r` when you want a layout to persist.

**One window per repo.** `prefix + c` opens a window in the current directory
and names it after that directory. The status bar is hidden by default so it
does not stack under Neovim; `prefix + b` shows or hides it when you need the
window list. `prefix + 1…9` jumps straight to one, and `prefix + &` closes one.

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
| `<leader>ee` | open or focus the Neo-tree project sidebar |
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
`mvn dependency:tree`, or `git log --oneline`; `Alt-t` again dismisses it. Your
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
| `prefix` + `b` | show or hide the tmux status bar |
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
| `%` | jump to the matching bracket, and back again |
| `]}` / `[{` | end / start of the enclosing `{ }`, from anywhere inside |
| `])` / `[(` | end / start of the enclosing `( )` |
| `]m` / `[m` | next / previous method **start** |
| `]M` / `[M` | next / previous method **end** |
| `{` / `}` | previous / next blank line — paragraph hops |
| `Ctrl-d` / `Ctrl-u` | half a screen down / up |
| `Ctrl-f` / `Ctrl-b` | full page down / up |
| `H` / `M` / `L` | top / middle / bottom of the visible screen |
| `zz` / `zt` / `zb` | scroll so the cursor sits centre / top / bottom |

`%` needs the cursor on a bracket — though if it is not, it jumps forward to
the first one on the line and matches that. `]}` needs nothing: it finds the
end of the block you are standing in. For "end of this function" in Java or Go,
`]M` goes straight there.

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

**On a whole block**, the same objects do the work without any jumping:

| | |
|---|---|
| `di{` / `ci{` | delete / clear a function or block body |
| `ya{` | yank the block including its braces |
| `=i{` | reindent the body |
| `gci{` | comment out the body |
| `va{` | select the block — press `a{` again to expand to the enclosing one |

That last one is the quick way to climb out of nested scopes.

### Commenting

| | |
|---|---|
| `gc` (visual) | toggle comments on the selection |
| `gcc` | toggle the current line |
| `gcap` | comment the whole paragraph |
| `gci{` | comment the enclosing block |
| `gc3j` | this line and the three below |
| `3gcc` | three lines |

`gc` is a Neovim built-in, not a plugin, and it toggles — press it again to
uncomment. The comment string comes from the buffer's `commentstring`, so it is
`//` in Java and Go, `--` in Lua, `#` in shell, and it stays correct inside
nested contexts like a `<script>` block in HTML.

`gcap` and `gci{` are the ones worth keeping: comment out a whole function body
without counting lines or selecting anything.

One limit — `gc` uses line comments, never block comments. In Java you get `//`
on each line rather than a `/* */` wrapper. That toggles cleanly, which is
usually the point, but a real block comment you write by hand.

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
| `]b` / `[b` | next / previous buffer, via the tab row |
| `Ctrl-w` `s` / `v` | split horizontally / vertically |
| `Ctrl-w` + `h` `j` `k` `l` | move between splits |
| `Ctrl-w` `o` | close every split but this one |
| `Ctrl-w` `q` | close this split |

**One gotcha:** inside an Oil listing, the normal editing keys are the file
operations — `dd` deletes a file, and changing a line's text renames it. Nothing
happens until you `:w`. See [File explorers](#file-explorers).

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
| `<leader>ee` | open/focus Neo-tree and reveal the current file |
| `<leader>et` / `<leader>ec` | toggle / close Neo-tree |
| `<leader>eo` / `<leader>ef` | editable directory / floating directory |
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
| `gqip` / `gwip` | reflow this paragraph to the width; `gw` keeps the cursor |
| `Esc` | clear search highlight |

`grn` versus `Ctrl-n` is the distinction worth internalising: `grn` asks jdtls or
gopls to rename the *symbol* everywhere including imports; `Ctrl-n` is multiple
cursors over *text* in this buffer. Reach for `grn` on anything the LSP knows.

### Completion

Two independent systems run at once. All of these are insert mode.

**The LSP menu** appears on its own as you type — every server attaches with
`autotrigger`.

| | |
|---|---|
| `Ctrl-n` / `Ctrl-p` | next / previous item (arrows work too) |
| `Ctrl-y` | **accept** |
| `Ctrl-e` | dismiss, keeping what you typed |
| `Ctrl-Space` | trigger it manually when the menu is not up |
| `Ctrl-s` | signature help — parameter hints |

Two things catch people out. **`Enter` accepts *and* inserts a newline** — use
`Ctrl-y`. And **`Tab` does not cycle the menu**; it is bound to snippet jumping
and falls through to a literal tab, so muscle memory from VS Code misfires here.

Nothing is preselected (`completeopt` carries `noselect`), so a `Ctrl-n` always
comes before the `Ctrl-y`. In exchange, typing never silently commits to a
completion. Also in that option: `fuzzy` so `stro` matches `StreamObserver`,
`nosort` to keep the server's own ranking, and `popup` for the documentation
preview beside the selected item.

**Copilot** is separate — greyed-out inline text, no menu.

| | |
|---|---|
| `Ctrl-Enter` | accept the whole suggestion |
| `Ctrl-Right` | accept one word at a time |
| `Ctrl-Up` / `Ctrl-Down` | cycle alternatives |

Word-by-word is the underrated one: take the first half of a suggestion and
type the rest yourself.

**Snippets.** Accepting a method completion usually inserts placeholders.

| | |
|---|---|
| `Tab` / `Shift-Tab` | jump between snippet placeholders |

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

### File explorers

`<leader>ee` opens or focuses the
[Neo-tree](https://github.com/nvim-neo-tree/neo-tree.nvim) sidebar and reveals
the current file. If the sidebar is already visible beside a file, the same key
moves focus into it. `<leader>et` toggles it and `<leader>ec` closes it. It shows
Git and diagnostic state, shows dotfiles, and hides Git-ignored items and `.git`.
The buffer tab row leaves an aligned Explorer header above the sidebar.

Inside Neo-tree, `Enter` or `l` opens or toggles an item, `h` closes a
directory, `P` previews, and `?` shows the complete key reference. The default
`a`, `d`, and `r` mappings add, delete, and rename. Space remains available as
the global leader inside the sidebar.

Oil remains available when the file list itself should be editable. Open it
with `<leader>eo` (the current file's directory), `<leader>ef` (the same in a
float), `nvim .`, or `:e <dir>`. The browser is
[oil.nvim](https://github.com/stevearc/oil.nvim), and the listing is a normal
buffer: edit it like text and write it to apply.

| | |
|---|---|
| `Enter` | open the file or descend into the directory |
| `-` | up to the parent directory |
| `Ctrl-s` / `Ctrl-h` | open in a vertical / horizontal split |
| `Ctrl-t` | open in a new tab |
| `Ctrl-p` | preview the file without leaving the listing |
| `Ctrl-l` | refresh the listing |
| `Ctrl-c` | close the listing |
| `g.` | toggle hidden files |
| `g\` | toggle the trash bin |
| `gs` | change the sort order |
| `gx` | open in the system default application |
| `g?` | show every key |

To **create, rename or delete**, edit the buffer and `:w`:

| | |
|---|---|
| add a line with a name | creates that file |
| add a line ending in `/` | creates a directory |
| add `a/b/c.lua` | creates the intervening directories too |
| change a line's text | renames |
| delete a line (`dd`) | deletes, to `~/.Trash` |

Writing shows a confirmation listing the pending operations — `y` applies. You
can stack several creates, renames and deletes into one `:w`. Icons come from
`mini.icons`; dotfiles are shown by default and `.git` is always hidden.

### Buffer tabs

The row along the top is one tab per open buffer, from
[bufferline.nvim](https://github.com/akinsho/bufferline.nvim). These are
buffers, not Neovim tabpages — opening a file adds a tab, and nothing needs a
`:tabnew`.

| | |
|---|---|
| `]b` / `[b` | next / previous buffer, matching `]c` / `[c` on git hunks |
| `<leader>bb` | label every tab and jump to the one you press |
| `<leader>bd` | close this buffer |
| `<leader>bo` | close every buffer but this one |
| `<leader>b.` / `<leader>b,` | move this tab right / left in the row |
| `<leader>fb` | the buffer list as an fzf picker, with preview |

A tab shows the filetype icon, and an LSP error or warning count when the file
has diagnostics. `<leader>fb` is still the faster way through a large set — the
row is for seeing what is open, the picker for searching it.

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

**Wrapping is 80, and it wraps prose and comments but never code.** The rulers
`cc = "80,120"` draws only paint — `textwidth` is what wraps, and it is the
option that was missing, which is why `t` and `c` sat in `formatoptions` doing
nothing for a long time. Now:

- **Comments** wrap as you type, in every filetype, and the `--` or `//` prefix
  carries onto the next line.
- **Code** never auto-wraps. `t` is deliberately absent from `formatoptions`, so
  a long string or call chain is left alone mid-edit; width is the formatter's
  job on save.
- **Markdown, text and commit messages** wrap as you type, and also soft-wrap
  into the window (`wrap` + `linebreak` + `breakindent`) so an existing long line
  folds at a space instead of running off the edge. Commit bodies use 72, git's
  convention, with the ruler moved to match.
- `gqip` reflows a paragraph on demand; `gwip` does it without moving the cursor.
- `l` in `formatoptions` means setting all this cannot reflow an existing file
  behind your back — only lines you are actively editing are touched.

The on-save formatters enforce the same 80: `prettier --print-width=80` and
`stylua.toml`'s `column_width = 80`. That `stylua.toml` is also what *enables*
Lua formatting at all — efm only runs stylua when it finds one, so before it
existed Lua was the single configured language that was never formatted. Its
settings match the Lua already committed here exactly, verified as zero rewritten
lines across all 23 files, so adding it reformatted nothing.

**Java follows Homebrew's current OpenJDK.** When `openjdk` is installed,
`.zshrc` discovers its prefix and puts `$JAVA_HOME/bin` on `$PATH`. Projects
that require another JDK can select it in `~/.zshrc.local` without changing the
shared configuration.

**Lombok needs a javaagent, and it is not in this repo.** Lombok generates
members during annotation processing, so `log` from `@Slf4j`, the accessors from
`@Getter` / `@Data` and the constructors from `@RequiredArgsConstructor` are
absent from the source jdtls reads — every one of them reports as unresolved
while Maven builds the project happily. IntelliJ bundles Lombok support; jdtls
needs the jar attached as a javaagent so it can patch the compiler it uses
internally. `lsp/jdtls.lua` adds the argument when the jar is present and starts
normally when it is not, so a fresh machine still gets a working Java setup —
just one that cannot see Lombok members until you run:

```sh
mkdir -p ~/.local/share/lombok
cp ~/.m2/repository/org/projectlombok/lombok/1.18.46/lombok-1.18.46.jar \
   ~/.local/share/lombok/lombok.jar
```

The jar lives outside the repo on purpose — 2MB of binary does not belong in
dotfiles. Any recent Lombok works; keep it new enough for the JDK in
`JAVA_HOME`, since Lombok support for a major Java release usually lands a few
versions behind.

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
are updated with the rest of tmux by `theme.sh`.

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

Not in this repo, and gitignored so they cannot be added by accident. `.zshrc`
reads `~/.zshsecrets` if present and stays quiet if it is missing.

GitHub CLI authentication remains in `~/.config/gh`, and SSH keys remain in
`~/.ssh`; neither path is managed or sourced by this repository. Use
`gh auth login` or your preferred credential manager on each laptop.

Repository automation must follow the safety contract in `AGENTS.md`. Its
required test suite exercises migration, collision refusal, rollback, private
backup permissions, and protected credential paths using temporary homes.

## Change the theme everywhere

The terminal tools share one visual theme. Check or change it from the
repository root:

```sh
./theme.sh status
./theme.sh tokyonight-moon
./theme.sh macchiato
./theme.sh mocha
```

The command updates Ghostty, Neovim, tmux, Starship, fzf (both shell and
Neovim), bat, and btop together. Reload the shell with `exec zsh`, reload tmux
with prefix + `r`, and restart other open applications. The selected theme is
stored in `.theme`; commit that change to carry the same look to another
laptop. Tokyo Night uses bat's ANSI theme so syntax colors follow the terminal
palette.

## Credit

The Neovim config and several shell helpers originate from
[ricoberger/dotfiles](https://github.com/ricoberger/dotfiles), since diverged.
