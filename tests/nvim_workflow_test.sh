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

cat > "$TEST_ROOT/tmux" <<'EOF'
#!/bin/sh
printf '%s\n' "$*" >> "$GMAYA_TMUX_TEST_LOG"
EOF
chmod +x "$TEST_ROOT/tmux"

GMAYA_TMUX_TEST_LOG="$TEST_ROOT/tmux-events" \
  PATH="$TEST_ROOT:$PATH" TMUX=fake nvim --headless README.md \
  '+lua local toggle = vim.fn.maparg("<leader>et", "n", false, true).callback; toggle(); assert(vim.wait(1000, function() if vim.fn.filereadable(vim.env.GMAYA_TMUX_TEST_LOG) == 0 then return false end for _, line in ipairs(vim.fn.readfile(vim.env.GMAYA_TMUX_TEST_LOG)) do if line:match("status%-position top$") then return true end end return false end)); toggle(); assert(vim.wait(1000, function() return vim.fn.filereadable(vim.env.GMAYA_TMUX_TEST_LOG) == 1 and #vim.fn.readfile(vim.env.GMAYA_TMUX_TEST_LOG) >= 3 end))' \
  '+qa!'
[[ $(sed -n '1p' "$TEST_ROOT/tmux-events") == \
  'set-option -g status-position bottom' ]]
[[ $(sed -n '2p' "$TEST_ROOT/tmux-events") == \
  'set-option -g status-position top' ]]
[[ $(sed -n '3p' "$TEST_ROOT/tmux-events") == \
  'set-option -g status-position bottom' ]]
pass 'tmux tabs follow Neo-tree visibility'

printf '1..%d\n' "$PASS_COUNT"
