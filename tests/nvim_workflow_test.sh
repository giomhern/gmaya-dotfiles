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
  '+lua assert(vim.o.laststatus == 3 and vim.o.showtabline == 0); assert(require("core.statusline").render():find("NORMAL", 1, true))' \
  '+qa!'
pass 'nvim dot opens one full-screen tree without an unnamed buffer'

TMUX= nvim --headless \
  '+lua local ok, err = pcall(function() vim.cmd.tabnew(); local other = vim.api.nvim_get_current_buf(); local other_tab = vim.api.nvim_get_current_tabpage(); vim.cmd.tabprevious(); vim.fn.maparg("<leader>ee", "n", false, true).callback(); assert(vim.wait(1000, function() return vim.bo.filetype == "neo-tree" end)); vim.wait(200); assert(vim.api.nvim_tabpage_is_valid(other_tab), "opening Neo-tree must not close another tab"); assert(vim.api.nvim_buf_is_valid(other), "second blank scratch must survive"); assert(vim.api.nvim_win_get_buf(vim.api.nvim_tabpage_list_wins(other_tab)[1]) == other) end); if not ok then io.stderr:write(tostring(err), "\n"); vim.cmd.cquit() end' \
  '+qa!'
pass 'opening Neo-tree leaves empty scratch buffers in other tabs intact'

TMUX= nvim --headless README.md \
  '+lua require("lazy").load({ plugins = { "which-key.nvim" } }); assert(package.loaded["which-key"]); local local_maps = vim.fn.maparg("<leader>?", "n", false, true); assert(type(local_maps.callback) == "function"); local config = require("which-key.config"); assert(config.options.preset == "modern"); assert(config.options.icons.mappings == false); assert(config.options.icons.keys.Space == "Space ")' \
  '+lua assert(vim.o.laststatus == 3 and vim.o.showtabline == 2); assert(require("core.statusline").render():find("README.md", 1, true))' \
  '+qa!'
pass 'which-key loads with the shared theme and textual icon policy'

TMUX= nvim --headless README.md \
  '+lua local ok, err = pcall(function() require("lazy").load({ plugins = { "blink.cmp" } }); local cmp = require("blink.cmp"); assert(type(cmp.get_lsp_capabilities) == "function"); local config = require("blink.cmp.config"); assert(config.keymap.preset == "super-tab"); assert(config.completion.list.selection.preselect({}) == false); assert(config.completion.list.selection.auto_insert({}) == false); assert(config.completion.ghost_text.enabled() == false); assert(vim.deep_equal(config.sources.default, { "lsp", "path", "snippets", "buffer" })); assert(vim.deep_equal(config.completion.menu.draw.columns({}), { { "label", "label_description", gap = 1 }, { "kind" } })); assert(config.cmdline.enabled == false) end); if not ok then print(err); vim.cmd.cquit() end' \
  '+qa!'
pass 'blink super-tab completion preserves Copilot and cmdline behavior'

TMUX= nvim --headless README.md \
  '+lua local ok, err = pcall(function() require("lazy").load({ plugins = { "noice.nvim", "diffview.nvim" } }); vim.api.nvim_exec_autocmds("VimEnter", {}); assert(vim.wait(1000, function() return require("noice.config").is_running() end)); local noice = require("noice.config").options; assert(noice.lsp.progress.enabled == false); assert(vim.tbl_isempty(noice.popupmenu.kind_icons)); assert(noice.presets.command_palette == true); assert(noice.cmdline.format.cmdline.icon == false and noice.cmdline.format.cmdline.conceal == false); assert(vim.fn.exists(":DiffviewOpen") == 2); assert(vim.fn.exists(":Noice") == 2); assert(vim.fn.maparg("<leader>gdo", "n", false, true).rhs:match("DiffviewOpen")); assert(vim.fn.maparg("<leader>nh", "n", false, true).rhs:match("Noice history")) end); if not ok then io.stderr:write(tostring(err), "\n"); vim.cmd.cquit() end' \
  '+qa!'
pass 'Noice and Diffview load with quiet progress and documented mappings'

TMUX= nvim --headless README.md \
  '+lua local ok, err = pcall(function() require("lazy").load({ plugins = { "noice.nvim" } }); vim.api.nvim_exec_autocmds("VimEnter", {}); assert(vim.wait(1000, function() return require("noice.config").is_running() end)); local cmdline = require("noice.ui.cmdline"); cmdline.on_show(nil, { { 0, "write" } }, 5, ":", "", 0, 1); assert(cmdline.message:content():sub(1, 6) == ":write", "Noice inserted a gap after the colon") end); if not ok then io.stderr:write(tostring(err), "\n"); vim.cmd.cquit() end' \
  '+qa!'
pass 'Noice renders command text directly beside the colon'

TMUX= nvim --headless . \
  '+lua local ok, err = pcall(function() assert(vim.wait(1500, function() return vim.bo.filetype == "neo-tree" end)); require("lazy").load({ plugins = { "noice.nvim", "which-key.nvim", "blink.cmp" } }); vim.api.nvim_exec_autocmds("VimEnter", {}); assert(vim.wait(1000, function() return require("noice.config").is_running() end)); local hl = function(name) return vim.api.nvim_get_hl(0, { name = name, link = false }) end; local canvas = hl("NeoTreeNormal").bg; assert(canvas); for _, name in ipairs({ "NormalFloat", "FloatBorder", "FloatTitle", "NeoTreeFloatNormal", "NeoTreeFloatBorder", "NeoTreeFloatTitle", "PickerNormal", "PickerBorder", "WhichKeyNormal", "WhichKeyBorder", "WhichKeyTitle", "NoicePopup", "NoicePopupBorder", "NoiceCmdlinePopup", "NoiceCmdlinePopupBorder", "BlinkCmpDoc", "BlinkCmpDocBorder", "BlinkCmpSignatureHelp", "BlinkCmpSignatureHelpBorder" }) do assert(hl(name).bg == canvas, name .. " differs from Neo-tree") end; assert(hl("Pmenu").bg == canvas); assert(hl("BlinkCmpMenuBorder").bg == canvas); assert(hl("NoicePopupmenuBorder").bg == canvas) end); if not ok then io.stderr:write(tostring(err), "\n"); vim.cmd.cquit() end' \
  '+qa!'
pass 'Neo-tree, Noice, WhichKey, Blink and picker popups share the explorer canvas'

TMUX= nvim --headless README.md \
  '+lua local ok, err = pcall(function() require("lazy").load({ plugins = { "octo.nvim" } }); local cfg = require("octo.config").values; assert(cfg.picker == "default" and cfg.use_local_fs == false and cfg.reviews.auto_show_threads); assert(vim.fn.exists(":Octo") == 2); for _, item in ipairs({ { "<leader>ghp", "Octo pr list" }, { "<leader>ghr", "Octo review browse" }, { "<leader>ghs", "Octo review" }, { "<leader>ghc", "Octo review close" } }) do assert(vim.fn.maparg(item[1], "n", false, true).rhs:find(item[2], 1, true), item[1]) end; assert(cfg.mappings.review_thread.add_reply.lhs == "<localleader>cr"); assert(cfg.mappings.review_thread.resolve_thread.lhs == "<localleader>rt"); assert(cfg.mappings.review_diff.next_thread.lhs == "]t") end); if not ok then io.stderr:write(tostring(err), "\n"); vim.cmd.cquit() end' \
  '+qa!'
pass 'Octo loads with read-only browse and explicit pending-review actions'

TMUX= nvim --headless README.md \
  '+lua local ok, err = pcall(function() vim.cmd.DiffviewOpen(); assert(vim.wait(2000, function() return #vim.api.nvim_list_tabpages() > 1 end)); local found = false; for _, b in ipairs(vim.api.nvim_list_bufs()) do if vim.bo[b].filetype:match("Diffview") then found = true end end; assert(found); vim.cmd.DiffviewClose(); assert(vim.wait(1000, function() return #vim.api.nvim_list_tabpages() == 1 end)) end); if not ok then io.stderr:write(tostring(err), "\n"); vim.cmd.cquit() end' \
  '+qa!'
pass 'Diffview opens the working-tree review and returns to the original tab'

TMUX= nvim --headless . \
  '+lua vim.wait(2000, function() return vim.bo.filetype == "neo-tree" end); vim.wait(300); vim.cmd.edit("README.md"); local file = vim.api.nvim_get_current_buf(); assert(vim.api.nvim_buf_get_name(file):match("README.md$")); local close = vim.fn.maparg("<leader>bd", "n", false, true).callback; close(); assert(vim.wait(1500, function() return vim.bo.filetype == "neo-tree" and not vim.api.nvim_buf_is_valid(file) end)); assert(#vim.api.nvim_tabpage_list_wins(0) == 1); for _, b in ipairs(vim.api.nvim_list_bufs()) do assert(not (vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_get_name(b) == "")) end' \
  '+qa!'
pass 'directory startup can open a file and return cleanly to the tree'

TMUX= nvim --headless . \
  '+lua local ok, err = pcall(function() local manager = require("neo-tree.sources.manager"); local renderer = require("neo-tree.ui.renderer"); local commands = require("neo-tree.sources.filesystem.commands"); local function open(name) assert(vim.wait(2000, function() local state = manager.get_state_for_window(); return state and state.tree and state.tree:get_node(vim.fn.getcwd() .. "/" .. name) end)); local state = manager.get_state_for_window(); renderer.focus_node(state, vim.fn.getcwd() .. "/" .. name); commands.open(state); assert(vim.wait(1000, function() return vim.api.nvim_buf_get_name(0):match(name .. "$") end)) end; open("README.md"); local readme = vim.api.nvim_get_current_buf(); vim.fn.maparg("<leader>ee", "n", false, true).callback(); assert(vim.wait(1000, function() return vim.bo.filetype == "neo-tree" end)); open("AGENTS.md"); local agents = vim.api.nvim_get_current_buf(); local close = vim.fn.maparg("<leader>bd", "n", false, true).callback; close(); assert(vim.api.nvim_get_current_buf() == readme and not vim.api.nvim_buf_is_valid(agents)); close(); assert(vim.wait(1500, function() return vim.bo.filetype == "neo-tree" and #require("core.buffers").files() == 0 end)); assert(#vim.api.nvim_tabpage_list_wins(0) == 1); for _, buf in ipairs(vim.api.nvim_list_bufs()) do assert(not require("core.buffers").is_empty_unnamed(buf)) end end); if not ok then io.stderr:write(tostring(err), "\n"); vim.cmd.cquit() end' \
  '+qa!'
pass 'real Neo-tree open, reopen, close-next, and full-screen fallback cycle'

TMUX= nvim --headless README.md \
  '+badd AGENTS.md' \
  '+lua local current = vim.api.nvim_get_current_buf(); local close = vim.fn.maparg("<leader>bd", "n", false, true).callback; assert(type(close) == "function"); close(); vim.wait(300); assert(not vim.api.nvim_buf_is_valid(current)); assert(vim.api.nvim_buf_get_name(0):match("AGENTS.md$")); assert(vim.bo.filetype ~= "neo-tree"); for _, b in ipairs(vim.api.nvim_list_bufs()) do assert(not (vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_get_name(b) == "")) end' \
  '+qa!'
pass 'closing a file selects the next open file'

TMUX= nvim --headless README.md \
  '+lua local ok, err = pcall(function() vim.cmd.vsplit(); local old = vim.api.nvim_get_current_buf(); vim.cmd.badd("AGENTS.md"); vim.fn.maparg("<leader>bd", "n", false, true).callback(); assert(not vim.api.nvim_buf_is_valid(old)); assert(#vim.api.nvim_tabpage_list_wins(0) == 2); for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do assert(vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)):match("AGENTS.md$")) end end); if not ok then io.stderr:write(tostring(err), "\n"); vim.cmd.cquit() end' \
  '+qa!'
pass 'closing a file shown in two splits preserves both windows'

TMUX= nvim --headless README.md \
  '+lua local current = vim.api.nvim_get_current_buf(); local close = vim.fn.maparg("<leader>bd", "n", false, true).callback; close(); vim.wait(1500, function() return vim.bo.filetype == "neo-tree" and not vim.api.nvim_buf_is_valid(current) end); assert(vim.bo.filetype == "neo-tree"); assert(#vim.api.nvim_tabpage_list_wins(0) == 1); assert(not vim.api.nvim_buf_is_valid(current)); for _, b in ipairs(vim.api.nvim_list_bufs()) do assert(not (vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_get_name(b) == "")) end' \
  '+lua assert(vim.wait(1000, function() return vim.o.showtabline == 0 end))' \
  '+qa!'
pass 'closing the last file returns to a full-screen tree'

TMUX= nvim --headless README.md \
  '+lua local ok, err = pcall(function() vim.cmd.vsplit(); local old = vim.api.nvim_get_current_buf(); vim.fn.maparg("<leader>bd", "n", false, true).callback(); assert(vim.wait(1500, function() return vim.bo.filetype == "neo-tree" and not vim.api.nvim_buf_is_valid(old) end)); assert(#vim.api.nvim_tabpage_list_wins(0) == 1) end); if not ok then io.stderr:write(tostring(err), "\n"); vim.cmd.cquit() end' \
  '+qa!'
pass 'closing the last file shown twice leaves one full-screen tree'

TMUX= nvim --headless README.md \
  '+lua local ok, err = pcall(function() local file = vim.api.nvim_get_current_buf(); vim.cmd.enew(); local blank = vim.api.nvim_get_current_buf(); assert(require("core.buffers").is_empty_unnamed(blank)); vim.fn.maparg("<leader>bd", "n", false, true).callback(); assert(vim.api.nvim_get_current_buf() == file); assert(not vim.api.nvim_buf_is_valid(blank)) end); if not ok then io.stderr:write(tostring(err), "\n"); vim.cmd.cquit() end' \
  '+qa!'
pass 'close empty unnamed buffer and return to an open file'

TMUX= nvim --headless README.md \
  '+lua local ok, err = pcall(function() local file = vim.api.nvim_get_current_buf(); vim.cmd.new(); local blank = vim.api.nvim_get_current_buf(); assert(#vim.api.nvim_tabpage_list_wins(0) == 2); vim.fn.maparg("<leader>bd", "n", false, true).callback(); assert(#vim.api.nvim_tabpage_list_wins(0) == 1); assert(vim.api.nvim_get_current_buf() == file); assert(not vim.api.nvim_buf_is_valid(blank)) end); if not ok then io.stderr:write(tostring(err), "\n"); vim.cmd.cquit() end' \
  '+qa!'
pass 'close accidental empty split without duplicating a file window'

TMUX= nvim --headless README.md \
  '+lua local ok, err = pcall(function() local file = vim.api.nvim_get_current_buf(); vim.fn.maparg("<leader>ee", "n", false, true).callback(); assert(vim.wait(1000, function() return vim.bo.filetype == "neo-tree" end)); vim.cmd.new(); local blank = vim.api.nvim_get_current_buf(); vim.fn.maparg("<leader>bd", "n", false, true).callback(); assert(vim.api.nvim_get_current_buf() == file, "should focus a file, not Neo-tree"); assert(not vim.api.nvim_buf_is_valid(blank)); assert(require("core.buffers").neo_tree_window()) end); if not ok then io.stderr:write(tostring(err), "\n"); vim.cmd.cquit() end' \
  '+qa!'
pass 'empty split beside Neo-tree returns focus to a real file'

TMUX= nvim --headless \
  '+lua local ok, err = pcall(function() vim.cmd.new(); local blank = vim.api.nvim_get_current_buf(); vim.fn.maparg("<leader>bd", "n", false, true).callback(); assert(vim.bo.filetype == "neo-tree"); assert(not vim.api.nvim_buf_is_valid(blank)); local wins = 0; for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do if vim.api.nvim_win_get_config(win).relative == "" then wins = wins + 1 end end; assert(wins == 1, "Neo-tree should be full-screen"); assert(#require("core.buffers").files() == 0) end); if not ok then io.stderr:write(tostring(err), "\n"); vim.cmd.cquit() end' \
  '+qa!'
pass 'last file-free split returns to full-screen Neo-tree'

TMUX= nvim --headless README.md \
  '+lua local ok, err = pcall(function() local file = vim.api.nvim_get_current_buf(); vim.cmd.tabnew(); local blank = vim.api.nvim_get_current_buf(); assert(#vim.api.nvim_list_tabpages() == 2); vim.fn.maparg("<leader>bd", "n", false, true).callback(); assert(#vim.api.nvim_list_tabpages() == 1); assert(vim.api.nvim_get_current_buf() == file); assert(not vim.api.nvim_buf_is_valid(blank)) end); if not ok then io.stderr:write(tostring(err), "\n"); vim.cmd.cquit() end' \
  '+qa!'
pass 'close accidental empty tab and return to the previous file'

TMUX= nvim --headless README.md \
  '+lua local ok, err = pcall(function() local file = vim.api.nvim_get_current_buf(); vim.cmd.tabnew(); local special = vim.api.nvim_get_current_buf(); vim.bo[special].buftype = "nofile"; vim.bo[special].filetype = "review-panel"; local review_tab = vim.api.nvim_get_current_tabpage(); vim.cmd.new(); local blank = vim.api.nvim_get_current_buf(); vim.fn.maparg("<leader>bd", "n", false, true).callback(); assert(vim.api.nvim_get_current_buf() == file); assert(not vim.api.nvim_buf_is_valid(blank)); assert(vim.api.nvim_tabpage_is_valid(review_tab)); assert(vim.api.nvim_buf_is_valid(special)); assert(vim.api.nvim_get_current_tabpage() ~= review_tab) end); if not ok then io.stderr:write(tostring(err), "\n"); vim.cmd.cquit() end' \
  '+qa!'
pass 'closing blank split returns to a hidden file without replacing review panes'

TMUX= nvim --headless \
  '+lua local ok, err = pcall(function() vim.cmd.tabnew(); local blank = vim.api.nvim_get_current_buf(); vim.fn.maparg("<leader>bd", "n", false, true).callback(); assert(#vim.api.nvim_list_tabpages() == 1); assert(vim.wait(1000, function() return vim.bo.filetype == "neo-tree" end)); assert(not vim.api.nvim_buf_is_valid(blank)) end); if not ok then io.stderr:write(tostring(err), "\n"); vim.cmd.cquit() end' \
  '+qa!'
pass 'closing an empty tab with no files returns to full-screen Neo-tree'

TMUX= nvim --headless \
  '+lua local ok, err = pcall(function() local blank = vim.api.nvim_get_current_buf(); assert(require("core.buffers").is_empty_unnamed(blank)); local float = vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), false, { relative = "editor", row = 1, col = 1, width = 10, height = 1, style = "minimal" }); vim.fn.maparg("<leader>bd", "n", false, true).callback(); assert(vim.wait(1000, function() return vim.bo.filetype == "neo-tree" end)); assert(not vim.api.nvim_buf_is_valid(blank)); vim.api.nvim_win_close(float, true); assert(#vim.api.nvim_tabpage_list_wins(0) == 1) end); if not ok then io.stderr:write(tostring(err), "\n"); vim.cmd.cquit() end' \
  '+qa!'
pass 'closing the sole empty buffer opens Neo-tree without another blank'

TMUX= nvim --headless README.md \
  '+lua local ok, err = pcall(function() local file = vim.api.nvim_get_current_buf(); vim.cmd.new(); local blank = vim.api.nvim_get_current_buf(); vim.api.nvim_set_current_win(vim.fn.bufwinid(file)); vim.fn.maparg("<leader>bd", "n", false, true).callback(); assert(vim.wait(1000, function() return vim.bo.filetype == "neo-tree" and not vim.api.nvim_buf_is_valid(file) end)); assert(not vim.api.nvim_buf_is_valid(blank)); assert(#vim.api.nvim_tabpage_list_wins(0) == 1) end); if not ok then io.stderr:write(tostring(err), "\n"); vim.cmd.cquit() end' \
  '+qa!'
pass 'closing last file clears disposable splits before full-screen Neo-tree'

TMUX= nvim --headless README.md \
  '+lua local ok, err = pcall(function() local file = vim.api.nvim_get_current_buf(); vim.cmd.new(); local scratch = vim.api.nvim_get_current_buf(); vim.api.nvim_buf_set_lines(scratch, 0, -1, false, { "keep this draft" }); vim.api.nvim_set_current_win(vim.fn.bufwinid(file)); vim.fn.maparg("<leader>bd", "n", false, true).callback(); assert(vim.wait(1000, function() return vim.bo.filetype == "neo-tree" and not vim.api.nvim_buf_is_valid(file) end)); assert(vim.api.nvim_buf_is_valid(scratch)); assert(vim.api.nvim_buf_get_lines(scratch, 0, 1, false)[1] == "keep this draft") end); if not ok then io.stderr:write(tostring(err), "\n"); vim.cmd.cquit() end' \
  '+qa!'
pass 'closing last file preserves a modified unnamed scratch split'

GMAYA_SCRATCH_TEST_PATH="$TEST_ROOT/new-file.md" TMUX= nvim --headless README.md \
  '+lua local ok, err = pcall(function() vim.cmd.enew(); local scratch = vim.api.nvim_get_current_buf(); vim.api.nvim_buf_set_lines(scratch, 0, -1, false, { "new file content" }); assert(not require("core.buffers").is_empty_unnamed(scratch)); vim.fn.maparg("<leader>bd", "n", false, true).callback(); assert(vim.api.nvim_get_current_buf() == scratch); assert(vim.api.nvim_buf_get_lines(scratch, 0, 1, false)[1] == "new file content"); vim.cmd("saveas " .. vim.fn.fnameescape(vim.env.GMAYA_SCRATCH_TEST_PATH)); assert(vim.uv.fs_realpath(vim.api.nvim_buf_get_name(0)) == vim.uv.fs_realpath(vim.env.GMAYA_SCRATCH_TEST_PATH)); assert(vim.fn.filereadable(vim.env.GMAYA_SCRATCH_TEST_PATH) == 1) end); if not ok then io.stderr:write(tostring(err), "\n"); vim.cmd.cquit() end' \
  '+qa!'
pass 'unnamed text survives close and can be named with saveas'

TMUX= nvim --headless README.md \
  '+lua local toggle = vim.fn.maparg("<leader>et", "n", false, true).callback; local focus = vim.fn.maparg("<leader>ee", "n", false, true).callback; assert(type(toggle) == "function" and type(focus) == "function"); toggle(); vim.wait(1000, function() return #vim.api.nvim_tabpage_list_wins(0) == 2 end); local tree, file; for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do local b = vim.api.nvim_win_get_buf(w); if vim.bo[b].filetype == "neo-tree" then tree = w else file = w end end; assert(tree and file); assert(vim.api.nvim_win_get_position(tree)[2] < vim.api.nvim_win_get_position(file)[2]); vim.api.nvim_set_current_win(file); focus(); assert(vim.api.nvim_get_current_win() == tree); toggle(); vim.wait(1000, function() return #vim.api.nvim_tabpage_list_wins(0) == 1 end); assert(vim.bo.filetype ~= "neo-tree"); toggle(); vim.wait(1000, function() return #vim.api.nvim_tabpage_list_wins(0) == 2 end)' \
  '+lua assert(vim.o.laststatus == 3 and vim.o.showtabline == 2); local file; for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do if vim.bo[vim.api.nvim_win_get_buf(w)].filetype ~= "neo-tree" then file = w end end; assert(file); vim.api.nvim_set_current_win(file); assert(require("core.statusline").render():find("README.md", 1, true))' \
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
