--------------------------------------------------------------------------------
-- GLOBALS
--------------------------------------------------------------------------------

-- Set the leader to " " (space).
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable some built-in plugins, so that they are not loaded.
vim.g.loaded_2html_plugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_gzip = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
-- Neo-tree replaces netrw for directory buffers. It handles both ":e <dir>"
-- and "nvim ." through its netrw hijack; see the EXPLORER section below.
vim.g.loaded_remote_plugins = 1
vim.g.loaded_rplugin = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_tohtml = 1
vim.g.loaded_tutor = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- We are using "Cascadia Code" as font in our terminal, so that we can enable
-- nerd font support in Neovim.
vim.g.have_nerd_font = true

-- Bootstrap lazy.nvim outside the repository so its manager and plugin state
-- remain local to this Neovim installation.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local output = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Failed to install lazy.nvim:\n" .. output)
  end
end
vim.opt.rtp:prepend(lazypath)

--------------------------------------------------------------------------------
-- OPTIONS
--------------------------------------------------------------------------------

vim.opt.background = "dark"
vim.opt.shada = "!,'100,<50,s10,h"
vim.opt.cc = "80" -- Display the default code-width ruler
-- The width the rulers above are drawn at, and the one stylua.toml and prettier
-- are both set to. The rulers only paint; textwidth is what actually wraps, and
-- it is 0 unless set, which is why "t" and "c" in formatoptions did nothing.
vim.opt.textwidth = 80
vim.opt.clipboard = "unnamedplus" -- Sync with system clipboard
-- Keep LSP progress out of the cmdline. Neovim 0.12 defaults to "progress:c",
-- which renders progress through the floating cmd / msg windows anchored to
-- "laststatus". A chatty server -- jdtls reports "Building" continuously --
-- grows that window to several rows and it does not shrink back, leaving a
-- blank block over the statusline and the tildes below the last line. Most
-- visible when inserting near the bottom of a file, where there is nothing
-- else drawn down there. Progress is still in ":messages".
vim.opt.messagesopt = "hit-enter,history:500,progress:"
vim.opt.cursorline = true -- Enable highlighting of the current line
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.exrc = true -- Look for .nvim.lua files in the project directory
-- "jcroqln", i.e. the old "jcroqlnt" minus "t". "c" wraps comments at textwidth
-- while typing, which is what an IDE does; "t" wrapped code as well, which no
-- formatter expects and which mangles a long string or call chain mid-edit. Code
-- width is the formatter's job on save. "l" leaves already-long lines alone, so
-- setting textwidth cannot reflow existing files behind your back, and "q" is
-- what lets "gq" reflow a paragraph on demand. Prose filetypes add "t" back in
-- the AUTO COMMANDS section below.
vim.opt.formatoptions = "jcroqln" -- Automatic formatting behavior
vim.opt.hlsearch = true -- Set highlight on search
vim.opt.ignorecase = true -- Ignore case
vim.opt.inccommand = "split" -- Show live preview of substitution
vim.opt.laststatus = 3 -- global statusline
vim.opt.list = true -- Show some invisible characters
vim.opt.listchars = { tab = "│ ", leadmultispace = "│ " } -- Set characters for invisible characters
vim.opt.mouse = "a" -- Enable mouse mode
vim.opt.number = true -- Print line number
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.scrolloff = 4 -- Lines of context
vim.opt.sessionoptions = { "buffers", "curdir", "folds", "tabpages", "winsize" }
vim.opt.shiftround = true -- Round indent
vim.opt.shiftwidth = 2 -- Size of an indent
vim.opt.shortmess = "I" -- Disable the intro message
-- showtabline is set to 2 in the BUFFERLINE section, which owns that row.
vim.opt.sidescrolloff = 8 -- Columns of context
vim.opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
vim.opt.smartcase = true -- Don't ignore case with capitals
vim.opt.smartindent = true -- Insert indents automatically
vim.opt.spell = false
vim.opt.spelllang = { "en_us" }
vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitkeep = "screen"
vim.opt.splitright = true -- Put new windows right of current
vim.opt.swapfile = false -- Disable swapfile
vim.opt.tabstop = 2 -- Number of spaces tabs count for
vim.opt.termguicolors = true -- True color support
vim.opt.timeout = false
vim.opt.timeoutlen = 300
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.updatetime = 200 -- Save swap file and trigger CursorHold
vim.opt.wrap = false -- File buffers enable soft wrapping below
vim.opt.wildignore = vim.opt.wildignore + ".DS_Store"

-- Folding
vim.opt.foldcolumn = "0"
vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldmethod = "syntax"
vim.opt.foldtext = ""

-- Better diff experience in Neovim.
vim.opt.diffopt = {
  "internal",
  "filler",
  "closeoff",
  "context:12",
  "algorithm:histogram",
  "indent-heuristic",
  -- See https://www.reddit.com/r/neovim/comments/1k24zgk/comment/moj5kxj/
  -- "linematch:200",
  "inline:char",
}

-- Enable strikethrough.
vim.cmd([[let &t_Ts = "\e[9m"]])
vim.cmd([[let &t_Te = "\e[29m"]])

-- Enable undercurls.
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

-- Enable the new Neovim UI, which is currently experimental.
require("vim._core.ui2").enable({
  enable = true,
  msg = {
    targets = "cmd",
  },
})

--------------------------------------------------------------------------------
-- FILETYPE HANDLING
--------------------------------------------------------------------------------

-- Custom filetype detection so the correct LSP servers can attach.
vim.filetype.add({
  extension = {
    -- Flutter translations
    arb = "json",
    -- gopls
    tmpl = "gotmpl",
    -- marksman--
    mdx = "markdown.mdx",
  },
  pattern = {
    -- docker_compose_language_service
    ["compose.*%.ya?ml"] = "yaml.docker-compose",
    ["docker%-compose.*%.ya?ml"] = "yaml.docker-compose",
    -- helm_ls
    [".*/templates/.*%.tpl"] = "helm",
    [".*/templates/.*%.ya?ml"] = "helm",
    [".*/templates/.*%.txt"] = "helm",
    ["helmfile.*%.ya?ml"] = "helm",
    ["helmfile.*%.ya?ml.gotmpl"] = "helm",
    ["values.*%.yaml"] = "yaml.helm-values",
    -- yamlls
    ["%.gitlab%-ci%.ya?ml"] = "yaml.gitlab",
  },
})

--------------------------------------------------------------------------------
-- AUTO COMMANDS
--------------------------------------------------------------------------------

-- Highlight on yank.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 250 })
  end,
})

-- Soft-wrap regular file buffers without changing their contents. UI buffers
-- such as Neo-tree keep their own layout. linebreak avoids splitting a word,
-- and breakindent aligns the continuation with the start of the original line.
vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType" }, {
  group = vim.api.nvim_create_augroup("file-soft-wrap", { clear = true }),
  callback = function()
    local path = vim.api.nvim_buf_get_name(0)
    if
      vim.bo.buftype == ""
      and path ~= ""
      and vim.fn.isdirectory(path) == 0
    then
      vim.opt_local.wrap = true
      vim.opt_local.linebreak = true
      vim.opt_local.breakindent = true
    end
  end,
})

-- Prose also hard-wraps as it is typed. Markdown gets twice the normal code
-- width so paragraphs have more room while retaining a visible stopping point.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "markdown.mdx", "text", "gitcommit" },
  group = vim.api.nvim_create_augroup("prose-wrap", { clear = true }),
  callback = function(args)
    vim.opt_local.formatoptions:append("t")
    -- A commit message is the one place the convention is not 80: git wraps the
    -- body at 72 so "git log" stays readable under its four-space indent.
    if args.match == "gitcommit" then
      vim.opt_local.textwidth = 72
      vim.opt_local.colorcolumn = "72"
    elseif args.match == "markdown" or args.match == "markdown.mdx" then
      vim.opt_local.textwidth = 160
      vim.opt_local.colorcolumn = "160"
      -- Reflow an existing long paragraph once it is edited instead of keeping
      -- the old line length merely because it predates this configuration.
      vim.opt_local.formatoptions:remove("l")
    end
  end,
})

-- Resize splits if window got resized.
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = vim.api.nvim_create_augroup("resize-splits", { clear = true }),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Show cursor line only in active window.
vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
  callback = function()
    local ok, cl = pcall(vim.api.nvim_win_get_var, 0, "auto-cursorline")
    if ok and cl then
      vim.wo.cursorline = true
      vim.api.nvim_win_del_var(0, "auto-cursorline")
    end
  end,
})

vim.api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
  callback = function()
    local cl = vim.wo.cursorline
    if cl then
      vim.api.nvim_win_set_var(0, "auto-cursorline", cl)
      vim.wo.cursorline = false
    end
  end,
})

--------------------------------------------------------------------------------
-- KEYMAPS
--------------------------------------------------------------------------------

-- Better up / down navigation for "j" / "down" and "k" / "up".
vim.keymap.set(
  { "n", "x" },
  "j",
  "v:count == 0 ? 'gj' : 'j'",
  { expr = true, silent = true }
)
vim.keymap.set(
  { "n", "x" },
  "<down>",
  "v:count == 0 ? 'gj' : 'j'",
  { expr = true, silent = true }
)
vim.keymap.set(
  { "n", "x" },
  "k",
  "v:count == 0 ? 'gk' : 'k'",
  { expr = true, silent = true }
)
vim.keymap.set(
  { "n", "x" },
  "<up>",
  "v:count == 0 ? 'gk' : 'k'",
  { expr = true, silent = true }
)

-- Splits are moved between with the built-in "Ctrl-w" + h/j/k/l (or arrows).
-- Ctrl+arrows are deliberately unbound: macOS reserves them for Mission Control
-- and space switching, so they never reach the terminal in the first place.

-- Resize windows using "Shift" and arrow keys.
vim.keymap.set("n", "<s-up>", "<cmd>resize +2<cr>")
vim.keymap.set("n", "<s-down>", "<cmd>resize -2<cr>")
vim.keymap.set("n", "<s-left>", "<cmd>vertical resize -2<cr>")
vim.keymap.set("n", "<s-right>", "<cmd>vertical resize +2<cr>")

-- Move lines up and down using "Alt" + "j" / "k" in normal, insert and visual
-- modes.
vim.keymap.set("n", "<m-j>", "<cmd>m .+1<cr>==")
vim.keymap.set("n", "<m-k>", "<cmd>m .-2<cr>==")
vim.keymap.set("i", "<m-j>", "<esc><cmd>m .+1<cr>==gi")
vim.keymap.set("i", "<m-k>", "<esc><cmd>m .-2<cr>==gi")
vim.keymap.set("x", "<m-j>", ":m '>+1<cr>gv=gv")
vim.keymap.set("x", "<m-k>", ":m '<-2<cr>gv=gv")

-- Better indenting in visual mode using "<" and ">".
vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")

-- Clear search with "Esc" in normal and insert mode.
vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>")

-- Copy a reference to the current buffer (filename, directory, path with line /
-- selection or the quickfix list) to the system clipboard, e.g. to paste it
-- into an AI chat.
vim.keymap.set({ "n", "x" }, "<leader>y", function()
  require("core.yank").menu()
end, { desc = "Copy file reference" })

--------------------------------------------------------------------------------
-- COMMAND LINE
--------------------------------------------------------------------------------

-- Automatically trigger autocompletion in command line for certain commands,
-- e.g. ":find", ":buffer", ":edit", etc.
vim.api.nvim_create_autocmd({ "CmdlineChanged", "CmdlineLeave" }, {
  pattern = { "*" },
  group = vim.api.nvim_create_augroup(
    "cmdline-autocompletion",
    { clear = true }
  ),
  callback = function(ev)
    local function should_enable_autocomplete()
      local cmdline_cmd = vim.fn.split(vim.fn.getcmdline(), " ")[1]
      return cmdline_cmd == "help"
        or cmdline_cmd == "h"
        or cmdline_cmd == "find"
        or cmdline_cmd == "buffer"
    end

    if ev.event == "CmdlineChanged" and should_enable_autocomplete() then
      vim.opt.wildmode = "noselect:lastused,full"
      vim.fn.wildtrigger()
    end

    if ev.event == "CmdlineLeave" then
      vim.opt.wildmode = "full"
    end
  end,
})

-- Better navigation of the command line wildmenu using the arrow keys. Also
-- Enter: doesn't execute the command, but instead accepts the currently
-- selected item in the wildmenu.
function _G.get_wildmenu_key(key_wildmenu, key_regular)
  return vim.fn.wildmenumode() ~= 0 and key_wildmenu or key_regular
end

vim.api.nvim_set_keymap(
  "c",
  "<down>",
  "v:lua.get_wildmenu_key('<right>', '<down>')",
  { expr = true }
)
vim.api.nvim_set_keymap(
  "c",
  "<up>",
  "v:lua.get_wildmenu_key('<left>', '<up>')",
  { expr = true }
)
vim.api.nvim_set_keymap(
  "c",
  "<cr>",
  "v:lua.get_wildmenu_key('<c-y>', '<cr>')",
  { expr = true }
)

--------------------------------------------------------------------------------
-- PLUGINS
--------------------------------------------------------------------------------

require("lazy").setup({
  spec = { { import = "plugins" } },
  checker = { enabled = false },
})

--------------------------------------------------------------------------------
-- FIND FILES
--------------------------------------------------------------------------------

local find_command =
  "fd --full-path --hidden --color never --type f --exclude .git --exclude node_modules --exclude dist --exclude .DS_Store"
local find_cache = {}

-- Use "fd" to find files with the "find" command. Together with the
-- "matchfuzzy()" function this should replace any external fuzzy finder plugin.
-- The files are cached until the command line is closed. Afterwards the cache
-- is cleared.
function _G.fd_find_files(arg, _)
  if #find_cache == 0 then
    find_cache = vim.fn.systemlist(find_command)
  end
  return #arg == 0 and find_cache or vim.fn.matchfuzzy(find_cache, arg)
end

vim.opt.findfunc = "v:lua.fd_find_files"

vim.api.nvim_create_autocmd({ "CmdlineLeave" }, {
  pattern = ":",
  group = vim.api.nvim_create_augroup(
    "find-command-clear-cache",
    { clear = true }
  ),
  callback = function(ev)
    if ev.event == "CmdlineLeave" then
      find_cache = {}
    end
  end,
})

-- Keymaps for finding files, buffers and recent files (filtered to the current
-- working directory) using our fzf based picker.
vim.keymap.set("n", "<leader>ff", function()
  require("core.picker").find_files()
end, { desc = "Find files" })
vim.keymap.set("n", "<leader>fb", function()
  require("core.picker").buffers()
end, { desc = "Find open buffers" })
vim.keymap.set("n", "<leader>fr", function()
  require("core.picker").recent()
end, { desc = "Find recent files" })

--------------------------------------------------------------------------------
-- SEARCH THROUGH FILES
--------------------------------------------------------------------------------

-- Use "rg" (ripgrep) to search though files with the "grep" command.
vim.opt.grepprg =
  "rg --vimgrep --smart-case --hidden --color=never --glob='!.git' --glob='!node_modules' --glob='!dist' --glob='!.DS_Store'"
vim.opt.grepformat = "%f:%l:%c:%m"

-- Keymaps for searching through files using our fzf based picker. "<leader>sw"
-- greps the word under the cursor (or the visual selection) and "<leader>st"
-- greps for common todo / warning tags.
vim.keymap.set("n", "<leader>ss", function()
  require("core.picker").grep_project()
end, { desc = "Search project" })
vim.keymap.set({ "n", "x" }, "<leader>sw", function()
  require("core.picker").grep_word()
end, { desc = "Search word or selection" })
vim.keymap.set("n", "<leader>st", function()
  require("core.picker").grep_todos()
end, { desc = "Search TODO markers" })

--------------------------------------------------------------------------------
-- REPLACE
--------------------------------------------------------------------------------

-- Replace in the current buffer or in all items in the quickfix list. Replace
-- in the current buffer also works for a visual selection.
vim.keymap.set(
  { "n" },
  "<leader>rr",
  [[:%s///gcI<left><left><left><left><left>]],
  { desc = "Replace in buffer" }
)
vim.keymap.set(
  "x",
  "<leader>rr",
  [[:s///gcI<left><left><left><left><left>]],
  { desc = "Replace in selection" }
)
vim.keymap.set(
  "n",
  "<leader>rw",
  [[:%s/\<<c-r><c-w>\>//gcI<left><left><left><left>]],
  { desc = "Replace word in buffer" }
)
vim.keymap.set(
  "x",
  "<leader>rw",
  [[y:%s/\V<c-r>"//gcI<left><left><left><left>]],
  { desc = "Replace selection in buffer" }
)
vim.keymap.set(
  "n",
  "<leader>rR",
  [[:cfdo %s///gcI | update]]
    .. [[<left><left><left><left><left><left><left><left><left><left><left><left><left><left>]],
  { desc = "Replace across quickfix files" }
)
vim.keymap.set(
  "n",
  "<leader>rW",
  [[:cfdo %s/\<<c-r><c-w>\>//gcI | update]]
    .. [[<left><left><left><left><left><left><left><left><left><left><left><left><left>]],
  { desc = "Replace word across quickfix files" }
)
vim.keymap.set(
  "x",
  "<leader>rW",
  [[y:cfdo %s/\V<c-r>"//gcI | update]]
    .. [[<left><left><left><left><left><left><left><left><left><left><left><left><left>]],
  { desc = "Replace selection across quickfix files" }
)

--------------------------------------------------------------------------------
-- QUICKFIX LIST
--------------------------------------------------------------------------------

-- Remove items from the quickfix list via "dd" in normal mode and "d" in
-- visual mode.
--
-- See: https://github.com/rmarganti/.dotfiles/blob/e08a5d8f1462b573e0cf9a01fb54403111b9aceb/dots/.config/nvim/lua/rmarganti/core/autocommands.lua#L12
local function delete_qf_items()
  local mode = vim.api.nvim_get_mode()["mode"]

  local start_idx
  local count

  if mode == "n" then
    start_idx = vim.fn.line(".")
    count = vim.v.count > 0 and vim.v.count or 1
  else
    local v_start_idx = vim.fn.line("v")
    local v_end_idx = vim.fn.line(".")

    start_idx = math.min(v_start_idx, v_end_idx)
    count = math.abs(v_end_idx - v_start_idx) + 1

    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes("<esc>", true, false, true),
      "x",
      false
    )
  end

  local qflist = vim.fn.getqflist()
  local title = vim.fn.getqflist({ title = 1 })

  for _ = 1, count, 1 do
    table.remove(qflist, start_idx)
  end

  vim.fn.setqflist({}, "r", { title = title.title, items = qflist })
  vim.fn.cursor(start_idx, 1)
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup(
    "delete-quickfix-items",
    { clear = true }
  ),
  pattern = "qf",
  callback = function()
    vim.keymap.set("n", "dd", delete_qf_items, { buffer = true })
    vim.keymap.set("x", "d", delete_qf_items, { buffer = true })
  end,
})

-- Automatically open the quickfix window if there are any entries in the
-- quickfix list, e.g. after running ":grep".
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  group = vim.api.nvim_create_augroup("auto-open-quickfix", { clear = true }),
  pattern = { "[^l]*" },
  command = "cwindow",
})

--------------------------------------------------------------------------------
-- LSP
--------------------------------------------------------------------------------

-- Enable and configure the built-in LSP client.
vim.lsp.enable({
  "bashls",
  "copilot",
  "dockerls",
  "docker_compose_language_service",
  "efm",
  "filepaths_ls",
  "golangci_lint_ls",
  "gopls",
  "jdtls",
  "lua_ls",
  "marksman",
  "my_hover_ls",
  "prlsp",
  "pyright",
  "sourcekit",
  "yamlls",
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    local buffer = event.buf

    if client then
      -- Add additional keymaps to the default LSP keymaps.
      -- See: https://neovim.io/doc/user/lsp.html#_global-defaults
      vim.keymap.set("n", "grf", function()
        vim.lsp.buf.format({
          timeout_ms = 60000,
        })
      end)
      vim.keymap.set("n", "gd", function()
        vim.lsp.buf.definition({ loclist = false })
      end)
      vim.keymap.set("n", "gD", function()
        vim.lsp.buf.declaration({ loclist = false })
      end)
      -- Jump to any symbol in the project by name. Neovim binds "gO" to
      -- document symbols out of the box but leaves workspace symbols unbound,
      -- and it is the fastest way around a Java or Go codebase — jdtls and
      -- gopls both index the whole workspace, so this beats walking the tree.
      vim.keymap.set("n", "gW", function()
        vim.lsp.buf.workspace_symbol()
      end)
      vim.keymap.set("n", "grh", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
      end)

      -- -- Add "<leader>mlo" keymap for tsgo to organize imports, since the
      -- -- default code action keymap "gra" does not provide it.
      -- vim.keymap.set("n", "<leader>mlo", function()
      --   vim.lsp.buf.code_action({
      --     context = { only = { "source.organizeImports" }, diagnostics = {} },
      --     apply = true,
      --   })
      -- end)

      -- Enable LLM-based inline completions.
      if
        client:supports_method(
          vim.lsp.protocol.Methods.textDocument_inlineCompletion
        )
      then
        vim.lsp.inline_completion.enable(true)

        -- Accept the currently shown inline completion with "Ctrl+Enter". If no
        -- inline completion is currently shown, insert a newline as usual.
        vim.keymap.set("i", "<c-cr>", function()
          if not vim.lsp.inline_completion.get() then
            return "<c-cr>"
          end
        end, { expr = true, replace_keycodes = true })

        -- Accept the currently shown inline completion word by word with
        -- "Ctrl+Right". If no inline completion is currently shown, move the
        -- cursor to the right as usual.
        vim.keymap.set("i", "<c-right>", function()
          if
            not vim.lsp.inline_completion.get({
              on_accept = function(item)
                local insert_text = item.insert_text
                if type(insert_text) ~= "string" or not item.range then
                  return nil
                end
                local end_ = item.range[4]

                local before_text = string.sub(insert_text, 1, end_)
                local after_text = string.sub(insert_text, end_ + 1)
                local next_word = string.match(after_text, "(%s?[^%s]+)")

                item.insert_text = before_text .. next_word
                return item
              end,
            })
          then
            return "<c-right>"
          end
        end, { expr = true, replace_keycodes = true })

        -- Cycle through the available inline completions with "Ctrl+Up" (next)
        -- and "Ctrl+Down" (previous).
        vim.keymap.set("i", "<c-up>", function()
          vim.lsp.inline_completion.select({ count = 1 })
        end)
        vim.keymap.set("i", "<c-down>", function()
          vim.lsp.inline_completion.select({ count = -1 })
        end)
      end

      -- Add normal-mode keymappings for signature help.
      if client:supports_method("textDocument/signatureHelp") then
        vim.keymap.set("n", "<c-s>", function()
          vim.lsp.buf.signature_help()
        end)
      end

      -- Enable folding based on LSP.
      if client:supports_method("textDocument/foldingRange") then
        local win = vim.api.nvim_get_current_win()
        vim.wo[win][0].foldmethod = "expr"
        vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
      end

      -- Auto-format on save.
      if client:supports_method("textDocument/formatting") then
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = buffer,
          callback = function()
            vim.lsp.buf.format({ bufnr = buffer, id = client.id })
          end,
        })
      end
    end

    -- If the prlsp client is attached, load the prlsp plugin and add keymaps
    -- for creating, replying to and showing review comments.
    if client and client.name == "prlsp" then
      require("core.prlsp")

      vim.keymap.set(
        { "n", "x" },
        "<leader>ghc",
        ":PRLSPCreateReviewComment<cr>",
        { silent = true, desc = "Create review comment" }
      )
      vim.keymap.set("n", "<leader>ghr", "<cmd>PRLSPReplyToReviewThread<cr>", {
        desc = "Reply to review thread",
      })
      vim.keymap.set("n", "<leader>ghs", "<cmd>PRLSPShowReviewThread<cr>", {
        desc = "Show review thread",
      })
      vim.keymap.set("n", "<leader>ghu", "<cmd>PRLSPRefreshReviewThreads<cr>", {
        desc = "Refresh review threads",
      })
    end
  end,
})

-- Show LSP progress messages. It will also show a progress bar via Ghostty. In
-- case Neovim is exiting while the LSP is still running, it will send an OSC
-- sequence to Ghostty to make sure the progress bar is removed.
vim.api.nvim_create_autocmd("LspProgress", {
  callback = function(event)
    local value = event.data.params.value or {}
    local msg = value.message or "done"

    vim.api.nvim_echo({ { msg } }, false, {
      id = "lsp",
      kind = "progress",
      source = "vim.lsp",
      title = value.title,
      status = value.kind ~= "end" and "running" or "success",
      percent = value.percentage,
    })
  end,
})

vim.api.nvim_create_autocmd({ "VimLeavePre", "ExitPre" }, {
  callback = function()
    if vim.env.TERM and vim.env.TERM:match("ghostty") then
      local osc = "\27]9;4;0;100\a"
      vim.api.nvim_chan_send(vim.v.stderr, osc)
    end
  end,
})

--------------------------------------------------------------------------------
-- DIAGNOSTICS
--------------------------------------------------------------------------------

local icons_diagnostics = require("core.icons").diagnostic

vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  virtual_text = {
    spacing = 4,
    source = "if_many",
    prefix = function(diagnostic)
      for d, icon in pairs(icons_diagnostics) do
        if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
          return icon
        end
      end
      return ""
    end,
    format = function(diagnostic)
      -- Replace newline and tab characters with space for more compact
      -- diagnostics.
      local message = diagnostic.message
        :gsub("\n", " ")
        :gsub("\t", " ")
        :gsub("%s+", " ")
        :gsub("^%s+", "")
      return message
    end,
  },
  -- virtual_lines = true,
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.HINT] = icons_diagnostics.Hint,
      [vim.diagnostic.severity.INFO] = icons_diagnostics.Info,
      [vim.diagnostic.severity.WARN] = icons_diagnostics.Warn,
      [vim.diagnostic.severity.ERROR] = icons_diagnostics.Error,
    },
    linehl = {
      [vim.diagnostic.severity.HINT] = "DiagnosticHint",
      [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
      [vim.diagnostic.severity.WARN] = "DiagnosticWarn",
      [vim.diagnostic.severity.ERROR] = "DiagnosticError",
    },
  },
})

for _, type in ipairs({ "Error", "Warn", "Hint", "Info" }) do
  vim.fn.sign_define("DiagnosticSign" .. type, {
    name = "DiagnosticSign" .. type,
    text = icons_diagnostics[type] .. " ",
    texthl = "Diagnostic" .. type,
  })
end

vim.keymap.set("n", "<leader>d", function()
  vim.diagnostic.setloclist()
end, { desc = "Buffer diagnostics" })

vim.keymap.set("n", "<leader>D", function()
  vim.diagnostic.setqflist()
end, { desc = "Workspace diagnostics" })

--------------------------------------------------------------------------------
-- STATUSLINE
--------------------------------------------------------------------------------

require("core.statusline")
