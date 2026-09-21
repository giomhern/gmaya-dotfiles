#!/usr/bin/env bash

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/gmaya-nvim-tests.XXXXXX")"
PASS_COUNT=0
trap 'rm -rf "$TEST_ROOT"' EXIT
cd "$REPO"

pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  printf 'ok %d - %s\n' "$PASS_COUNT" "$1"
}

TMUX= nvim --headless . \
  '+lua vim.wait(2000, function() return vim.bo.filetype == "neo-tree" end); vim.wait(300); assert(vim.bo.filetype == "neo-tree"); assert(#vim.api.nvim_tabpage_list_wins(0) == 1); local toggle = vim.fn.maparg("<leader>et", "n", false, true).callback; toggle(); vim.wait(100); assert(vim.bo.filetype == "neo-tree"); assert(#vim.api.nvim_tabpage_list_wins(0) == 1); for _, b in ipairs(vim.api.nvim_list_bufs()) do assert(not (vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_get_name(b) == ""), "unnamed buffer " .. b) end' \
  '+qa!'
pass 'nvim dot opens one full-screen tree without an unnamed buffer'

TMUX= nvim --headless README.md \
  '+lua require("lazy").load({ plugins = { "which-key.nvim" } }); assert(package.loaded["which-key"]); local local_maps = vim.fn.maparg("<leader>?", "n", false, true); assert(type(local_maps.callback) == "function"); local config = require("which-key.config"); assert(config.options.preset == "modern"); assert(config.options.icons.mappings == false); assert(config.options.icons.keys.Space == "Space ")' \
  '+qa!'
pass 'which-key loads with the shared theme and textual icon policy'

TMUX= nvim --headless . \
  '+lua vim.wait(2000, function() return vim.bo.filetype == "neo-tree" end); vim.wait(300); vim.cmd.edit("README.md"); local file = vim.api.nvim_get_current_buf(); assert(vim.api.nvim_buf_get_name(file):match("README.md$")); local close = vim.fn.maparg("<leader>bd", "n", false, true).callback; close(); assert(vim.wait(1500, function() return vim.bo.filetype == "neo-tree" and not vim.api.nvim_buf_is_valid(file) end)); assert(#vim.api.nvim_tabpage_list_wins(0) == 1); for _, b in ipairs(vim.api.nvim_list_bufs()) do assert(not (vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_get_name(b) == "")) end' \
  '+qa!'
pass 'directory startup can open a file and return cleanly to the tree'

TMUX= nvim --headless README.md \
  '+badd AGENTS.md' \
  '+lua local current = vim.api.nvim_get_current_buf(); local close = vim.fn.maparg("<leader>bd", "n", false, true).callback; assert(type(close) == "function"); close(); vim.wait(300); assert(not vim.api.nvim_buf_is_valid(current)); assert(vim.api.nvim_buf_get_name(0):match("AGENTS.md$")); assert(vim.bo.filetype ~= "neo-tree"); for _, b in ipairs(vim.api.nvim_list_bufs()) do assert(not (vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_get_name(b) == "")) end' \
  '+qa!'
pass 'closing a file selects the next open file'

TMUX= nvim --headless README.md \
  '+lua local current = vim.api.nvim_get_current_buf(); local close = vim.fn.maparg("<leader>bd", "n", false, true).callback; close(); vim.wait(1500, function() return vim.bo.filetype == "neo-tree" and not vim.api.nvim_buf_is_valid(current) end); assert(vim.bo.filetype == "neo-tree"); assert(#vim.api.nvim_tabpage_list_wins(0) == 1); assert(not vim.api.nvim_buf_is_valid(current)); for _, b in ipairs(vim.api.nvim_list_bufs()) do assert(not (vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_get_name(b) == "")) end' \
  '+qa!'
pass 'closing the last file returns to a full-screen tree'

TMUX= nvim --headless README.md \
  '+lua local toggle = vim.fn.maparg("<leader>et", "n", false, true).callback; local focus = vim.fn.maparg("<leader>ee", "n", false, true).callback; assert(type(toggle) == "function" and type(focus) == "function"); toggle(); vim.wait(1000, function() return #vim.api.nvim_tabpage_list_wins(0) == 2 end); local tree, file; for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do local b = vim.api.nvim_win_get_buf(w); if vim.bo[b].filetype == "neo-tree" then tree = w else file = w end end; assert(tree and file); vim.api.nvim_set_current_win(file); focus(); assert(vim.api.nvim_get_current_win() == tree); toggle(); vim.wait(1000, function() return #vim.api.nvim_tabpage_list_wins(0) == 1 end); assert(vim.bo.filetype ~= "neo-tree"); toggle(); vim.wait(1000, function() return #vim.api.nvim_tabpage_list_wins(0) == 2 end)' \
  '+qa!'
pass 'explorer focus and toggle preserve the file window'

TMUX= nvim --headless README.md \
  '+lua assert(vim.bo.filetype == "markdown"); assert(vim.wo.wrap and vim.wo.linebreak and vim.wo.breakindent); assert(vim.bo.textwidth == 160); assert(vim.wo.colorcolumn == "160"); assert(not vim.bo.formatoptions:find("l", 1, true)); local efm = dofile(".config/nvim/lsp/efm.lua"); assert(efm.settings.languages.markdown[1].formatCommand:match("%-%-print%-width=160")); assert(efm.settings.languages["markdown.mdx"][1].formatCommand:match("%-%-print%-width=160")); local preview = vim.fn.maparg("<leader>pv", "n", false, true).callback; assert(type(preview) == "function"); assert(vim.fn.exists(":PreviewFile") == 2); assert(vim.fn.exists(":RenderMarkdown") == 2); preview(); vim.wait(100); preview()' \
  '+qa!'
pass 'Markdown uses its wider ruler, wraps, and toggles preview'

TMUX= nvim --headless .config/nvim/init.lua \
  '+lua assert(vim.bo.filetype == "lua"); assert(vim.wo.wrap and vim.wo.linebreak and vim.wo.breakindent); assert(vim.bo.textwidth == 80); assert(vim.wo.colorcolumn == "80"); assert(not vim.bo.formatoptions:find("t", 1, true))' \
  '+qa!'
pass 'code buffers soft-wrap at the normal ruler without changing text'

TMUX= nvim --headless install.sh \
  '+lua assert(vim.bo.filetype == "sh"); assert(vim.treesitter.language.get_lang(vim.bo.filetype) == "bash"); assert(vim.treesitter.query.get("bash", "highlights")); local query = vim.treesitter.query.get("bash", "highlights"); local root = vim.treesitter.get_parser(0, "bash"):parse()[1]:root(); local count = 0; for _ in query:iter_captures(root, 0, 0, -1) do count = count + 1; if count > 0 then break end end; assert(count > 0)' \
  '+qa!'
pass 'shell buffers load Bash Treesitter highlight queries'

cat > "$TEST_ROOT/open" <<'EOF'
#!/bin/sh
printf '%s\n' "$*" >> "$GMAYA_OPEN_TEST_LOG"
EOF
chmod +x "$TEST_ROOT/open"
printf 'fake pdf\n' > "$TEST_ROOT/sample.pdf"

GMAYA_OPEN_TEST_LOG="$TEST_ROOT/open-events" \
  PATH="$TEST_ROOT:$PATH" TMUX= nvim --headless "$TEST_ROOT/sample.pdf" \
  '+lua local preview = vim.fn.maparg("<leader>pv", "n", false, true).callback; assert(type(preview) == "function"); preview(); assert(vim.wait(1000, function() return vim.fn.filereadable(vim.env.GMAYA_OPEN_TEST_LOG) == 1 end))' \
  '+qa!'
[[ $(cat "$TEST_ROOT/open-events") == \
  "-a Preview $TEST_ROOT/sample.pdf" ]]
pass 'PDF preview opens the exact file without launching a GUI in tests'

cat > "$TEST_ROOT/tmux" <<'EOF'
#!/bin/sh
printf '%s\n' "$*" >> "$GMAYA_TMUX_TEST_LOG"
EOF
chmod +x "$TEST_ROOT/tmux"

GMAYA_TMUX_TEST_LOG="$TEST_ROOT/tmux-events" \
  PATH="$TEST_ROOT:$PATH" TMUX=fake nvim --headless README.md \
  '+lua local toggle = vim.fn.maparg("<leader>et", "n", false, true).callback; toggle(); assert(vim.wait(1000, function() return #vim.api.nvim_tabpage_list_wins(0) == 2 end)); toggle(); assert(vim.wait(1000, function() return #vim.api.nvim_tabpage_list_wins(0) == 1 end)); vim.cmd.tabnew(); vim.cmd.tabprevious()' \
  '+qa!'
[[ ! -e "$TEST_ROOT/tmux-events" ]]
pass 'Neo-tree and tab events do not change tmux options'

printf '1..%d\n' "$PASS_COUNT"
