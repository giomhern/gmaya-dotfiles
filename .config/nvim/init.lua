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
-- netrw is not disabled here either. oil.nvim takes over ":e <dir>" and "nvim ."
-- via "default_file_explorer", which hijacks netrw's autocmds rather than
-- needing it unloaded; setting these would only break oil's fallbacks. See the
-- EXPLORER section below.
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

--------------------------------------------------------------------------------
-- OPTIONS
--------------------------------------------------------------------------------

vim.opt.background = "dark"
vim.opt.shada = "!,'100,<50,s10,h"
vim.opt.cc = "80,120" -- Display rulers
-- The width the rulers above are drawn at, and the one stylua.toml and prettier
-- are both set to. The rulers only paint; textwidth is what actually wraps, and
-- it is 0 unless set, which is why "t" and "c" in formatoptions did nothing.
vim.opt.textwidth = 80
vim.opt.clipboard = "unnamedplus" -- Sync with system clipboard
vim.opt.completeopt = { "menuone", "noselect", "fuzzy", "nosort", "popup" } -- Better completion experience
vim.opt.pumheight = 10 -- Cap the completion menu; unbounded it blankets the file when completing near the bottom
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
vim.opt.wrap = false -- Disable line wrap
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

-- Prose wraps as you type; code does not. Adding "t" back means a paragraph
-- breaks at textwidth while writing it, the way it already does for comments
-- everywhere else. "wrap" plus "linebreak" also folds any line that is already
-- long into the window instead of running it off the right edge, breaking at a
-- space rather than mid-word, and "breakindent" keeps the continuation lined up
-- under the list marker it belongs to.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "markdown.mdx", "text", "gitcommit" },
  group = vim.api.nvim_create_augroup("prose-wrap", { clear = true }),
  callback = function(args)
    vim.opt_local.formatoptions:append("t")
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    -- A commit message is the one place the convention is not 80: git wraps the
    -- body at 72 so "git log" stays readable under its four-space indent.
    if args.match == "gitcommit" then
      vim.opt_local.textwidth = 72
      vim.opt_local.colorcolumn = "72"
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
end)

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
-- COLORSCHEME
--------------------------------------------------------------------------------

-- Set borders for floating windows, popup menus and the command line completion
-- menu. Also set a custom background color for the popup menu and a border
-- color.
vim.opt.winborder = "single"
vim.opt.pumborder = "single"

-- Use the built-in plugin manager to install the Catppuccin theme
--
-- See: https://neovim.io/doc/user/pack.html#_plugin-manager
-- To update all plugins run ":lua vim.pack.update()"
vim.pack.add({
  {
    src = "https://github.com/catppuccin/nvim",
    name = "catppuccin",
    version = "main",
  },
}, { confirm = false, load = true })

-- Setup the Catppuccin theme, by disabling all default integrations and only
-- activating the integrations we are really using.
require("catppuccin").setup({
  flavour = "mocha",
  default_integrations = false,
  integrations = {
    gitsigns = true,
    native_lsp = {
      enabled = true,
      virtual_text = {
        errors = { "italic" },
        hints = { "italic" },
        warnings = { "italic" },
        information = { "italic" },
        ok = { "italic" },
      },
      underlines = {
        errors = { "undercurl" },
        hints = { "undercurl" },
        warnings = { "undercurl" },
        information = { "undercurl" },
        ok = { "undercurl" },
      },
      inlay_hints = {
        background = true,
      },
    },
    treesitter = true,
  },
  custom_highlights = function(colors)
    local highlights = {
      Pmenu = { bg = colors.mantle },
      PmenuBorder = { bg = colors.mantle, fg = colors.blue },

      -- Picker (see "lua/core/picker.lua").
      PickerNormal = { bg = colors.base },
      PickerBorder = { bg = colors.base, fg = colors.blue },

      -- Explorer marks (see "lua/core/explorer.lua").
      ExplorerMark = { fg = colors.rosewater },
      ExplorerMarkLine = { bg = colors.surface0 },

      -- Statusline (see "lua/core/statusline.lua").
      StatuslineC = { fg = colors.text, bg = colors.mantle },
      StatuslineCompSepB = { fg = colors.overlay1, bg = colors.surface0 },
      StatuslineCompSepC = { fg = colors.text, bg = colors.mantle },
      StatuslineSepBC = { fg = colors.surface0, bg = colors.mantle },
      StatuslineSepXY = { fg = colors.surface0, bg = colors.mantle },
      StatuslineDiagError = { fg = colors.red, bg = colors.surface0 },
      StatuslineDiagWarn = { fg = colors.yellow, bg = colors.surface0 },
      StatuslineDiagInfo = { fg = colors.sky, bg = colors.surface0 },
      StatuslineDiagHint = { fg = colors.teal, bg = colors.surface0 },
      StatuslineDiffAdd = { fg = colors.green, bg = colors.surface0 },
      StatuslineDiffChange = { fg = colors.yellow, bg = colors.surface0 },
      StatuslineDiffDelete = { fg = colors.red, bg = colors.surface0 },
    }

    -- Mode-dependent statusline groups, one set per mode color. The key
    -- (e.g. "blue") is used as the highlight group suffix in statusline.lua.
    local mode_colors = {
      blue = colors.blue,
      green = colors.green,
      mauve = colors.mauve,
      red = colors.red,
      peach = colors.peach,
    }
    for key, color in pairs(mode_colors) do
      highlights["StatuslineA_" .. key] =
        { fg = colors.mantle, bg = color, bold = true }
      highlights["StatuslineZ_" .. key] =
        { fg = colors.mantle, bg = color, bold = true }
      highlights["StatuslineB_" .. key] = { fg = color, bg = colors.surface0 }
      highlights["StatuslineSepAB_" .. key] =
        { fg = color, bg = colors.surface0 }
      highlights["StatuslineSepYZ_" .. key] =
        { fg = color, bg = colors.surface0 }
      highlights["StatuslineSepAC_" .. key] = { fg = color, bg = colors.mantle }
    end

    return highlights
  end,
})

vim.cmd.colorscheme("catppuccin-nvim")

--------------------------------------------------------------------------------
-- EXPLORER
--------------------------------------------------------------------------------

-- Directory browsing is oil.nvim. Editing a directory path ("nvim .", ":e src/",
-- or "<leader>ee" below) opens the listing as a normal, editable buffer: rename
-- a file by changing its line, create one by adding a line, delete by removing
-- one, then ":w" to apply. "<CR>" opens, "-" goes up, "g?" lists every key.
--
-- netrw is what this replaced. It cannot draw filetype icons at all, and its
-- tree bars render in "Special", competing with the filenames. oil takes over
-- directory editing through "default_file_explorer", which disables netrw.
--
-- "core.explorer" is still NOT loaded, but it is now worth reviving: it was
-- written against a browser that set "filetype=directory" and rendered one
-- entry per line with no header, which is much closer to what oil produces than
-- to netrw's banner-and-tree listing. Its marking, bulk move/copy and
-- directory-grep are the parts worth porting.
vim.pack.add({
  {
    src = "https://github.com/stevearc/oil.nvim",
    name = "oil",
    version = "master",
  },
  {
    src = "https://github.com/echasnovski/mini.icons",
    name = "mini-icons",
    version = "main",
  },
}, { confirm = false, load = true })

-- oil asks for icons through the nvim-web-devicons API, which mini.icons can
-- answer once mocked. mini.icons is the lighter of the two and already themes
-- itself from the colorscheme, so no icon highlight wiring here either.
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()

require("oil").setup({
  default_file_explorer = true,
  columns = { "icon" },
  delete_to_trash = true,
  watch_for_changes = true,
  view_options = {
    -- Show dotfiles: this is a dotfiles repo, hiding them would hide the point.
    -- "g." toggles at runtime. The git directory is the one thing always hidden,
    -- since nothing in it should be edited through a file listing.
    show_hidden = true,
    is_always_hidden = function(name, _)
      return name == ".git"
    end,
  },
  -- The popup that lists pending changes on ":w". Its defaults are a min_width
  -- of "the greater of 40 columns or 40% of the editor" and a min_height of 5,
  -- so creating one file drew a half-screen box holding a single line. These
  -- floors let it shrink to its content. Rounded to match the tmux kill menus.
  confirmation = {
    min_width = 30,
    max_width = 0.6,
    min_height = 3,
    max_height = 0.6,
    border = "rounded",
    win_options = {
      -- Floats default to NormalFloat, which catppuccin paints mantle (#181825)
      -- against an editor of base (#1e1e2e). Point it at Normal so the box sits
      -- on the same background as the buffer behind it and as the fzf picker,
      -- which hardcodes base in "core.picker". FloatBorder is already the same
      -- blue the picker uses, so only the fill needed redirecting. "EndOfBuffer:"
      -- is oil's own entry, kept because setting win_options replaces the lot.
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder,EndOfBuffer:",
      winblend = 0,
    },
  },
  -- A directory listing is not a file, so drop the editing chrome it would
  -- inherit: the "80,120" rulers and the listchars indent guides both draw
  -- straight through the listing, and line numbers on a file list are noise.
  win_options = {
    colorcolumn = "",
    list = false,
    number = false,
    relativenumber = false,
    signcolumn = "no",
    cursorline = true,
  },
})

vim.keymap.set("n", "<leader>ee", function()
  local bufname = vim.api.nvim_buf_get_name(0)
  local dir
  if bufname == "" then
    dir = vim.fn.getcwd()
  elseif vim.fn.isdirectory(bufname) == 1 then
    dir = bufname
  else
    dir = vim.fn.fnamemodify(bufname, ":p:h")
  end
  require("oil").open(dir)
end)

-- The listing in a centered float, for when it should not disturb the window
-- layout. "<leader>ee" keeps the full-window listing.
vim.keymap.set("n", "<leader>ef", function()
  require("oil").open_float()
end)

-- Keymap to save a file without running any auto commands and with creating
-- directories.
vim.keymap.set("n", "<leader>ew", "<cmd>noautocmd write ++p<cr>")

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
end)
vim.keymap.set("n", "<leader>fb", function()
  require("core.picker").buffers()
end)
vim.keymap.set("n", "<leader>fr", function()
  require("core.picker").recent()
end)

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
end)
vim.keymap.set({ "n", "x" }, "<leader>sw", function()
  require("core.picker").grep_word()
end)
vim.keymap.set("n", "<leader>st", function()
  require("core.picker").grep_todos()
end)

--------------------------------------------------------------------------------
-- REPLACE
--------------------------------------------------------------------------------

-- Replace in the current buffer or in all items in the quickfix list. Replace
-- in the current buffer also works for a visual selection.
vim.keymap.set(
  { "n" },
  "<leader>rr",
  [[:%s///gcI<left><left><left><left><left>]]
)
vim.keymap.set("x", "<leader>rr", [[:s///gcI<left><left><left><left><left>]])
vim.keymap.set(
  "n",
  "<leader>rw",
  [[:%s/\<<c-r><c-w>\>//gcI<left><left><left><left>]]
)
vim.keymap.set(
  "x",
  "<leader>rw",
  [[y:%s/\V<c-r>"//gcI<left><left><left><left>]]
)
vim.keymap.set(
  "n",
  "<leader>rR",
  [[:cfdo %s///gcI | update]]
    .. [[<left><left><left><left><left><left><left><left><left><left><left><left><left><left>]]
)
vim.keymap.set(
  "n",
  "<leader>rW",
  [[:cfdo %s/\<<c-r><c-w>\>//gcI | update]]
    .. [[<left><left><left><left><left><left><left><left><left><left><left><left><left>]]
)
vim.keymap.set(
  "x",
  "<leader>rW",
  [[y:cfdo %s/\V<c-r>"//gcI | update]]
    .. [[<left><left><left><left><left><left><left><left><left><left><left><left><left>]]
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
-- TREESITTER
--------------------------------------------------------------------------------

-- Install the nvim-treesitter plugin and ensure that some parsers are always
-- installed. We also allow auto installing of additional parsers.
vim.pack.add({
  {
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    name = "nvim-treesitter",
    version = "main",
  },
}, { confirm = false, load = true })

require("nvim-treesitter").setup({
  install_dir = vim.fn.stdpath("data") .. "/site",
})

local ts_parsers = {
  "bash",
  "css",
  "dart",
  "diff",
  "dockerfile",
  "git_config",
  "git_rebase",
  "gitattributes",
  "gitcommit",
  "gitignore",
  "go",
  "gomod",
  "gosum",
  "helm",
  "html",
  "javascript",
  "json",
  "lua",
  "make",
  "markdown",
  "markdown_inline",
  "python",
  "regex",
  "rust",
  "sql",
  "terraform",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "yaml",
  "zig",
}

local ts = require("nvim-treesitter")
vim.schedule(function()
  ts.install(ts_parsers)
end)

-- Update treesitter parsers / queries with plugin updates.
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup(
    "nvim-treesitter-pack-update-handler",
    { clear = true }
  ),
  callback = function(event)
    local spec = event.data.spec
    if
      spec
      and spec.name == "nvim-treesitter"
      and event.data.kind == "update"
    then
      vim.schedule(function()
        ts.update()
      end)
    end
  end,
})

-- Enable treesitter highlighting and indents.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup(
    "nvim-treesitter-enable-highlighting-and-indents-handler",
    { clear = true }
  ),
  callback = function(event)
    local filetype = event.match
    local lang = vim.treesitter.language.get_lang(filetype)
    if lang and vim.treesitter.language.add(lang) then
      if vim.treesitter.query.get(filetype, "indents") then
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
      if vim.treesitter.query.get(filetype, "folds") then
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo.foldmethod = "expr"
      end
      vim.treesitter.start()
    end
  end,
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
  "terraformls",
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

      -- Enable completion.
      if
        client:supports_method(vim.lsp.protocol.Methods.textDocument_completion)
      then
        vim.lsp.completion.enable(
          true,
          client.id,
          buffer,
          { autotrigger = true }
        )
        vim.keymap.set("i", "<c-space>", function()
          vim.lsp.completion.get()
        end)
      end

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
        { silent = true }
      )
      vim.keymap.set("n", "<leader>ghr", "<cmd>PRLSPReplyToReviewThread<cr>")
      vim.keymap.set("n", "<leader>ghs", "<cmd>PRLSPShowReviewThread<cr>")
      vim.keymap.set("n", "<leader>ghu", "<cmd>PRLSPRefreshReviewThreads<cr>")
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

local icons_diagnostics = {
  Error = " ",
  Warn = " ",
  Info = " ",
  Hint = " ",
}

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
    text = icons_diagnostics[type],
    texthl = "Diagnostic" .. type,
  })
end

vim.keymap.set("n", "<leader>d", function()
  vim.diagnostic.setloclist()
end, {})

vim.keymap.set("n", "<leader>D", function()
  vim.diagnostic.setqflist()
end, {})

--------------------------------------------------------------------------------
-- STATUSLINE
--------------------------------------------------------------------------------

require("core.statusline")

--------------------------------------------------------------------------------
-- BUFFERLINE
--------------------------------------------------------------------------------

-- One tab per open buffer along the top. Buffers, not tabpages: Neovim's own
-- ":tabs" are separate window layouts, and this config barely uses them, so the
-- row tracks what is actually open. Icons come from the mini.icons devicons
-- mock set up in the EXPLORER section above, which is why this block has to
-- follow it.
--
-- This catppuccin build ships no bufferline integration, so bufferline derives
-- its palette from the colorscheme instead. Only the fills are pinned below, to
-- the same base / mantle split the oil confirmation and the fzf picker use:
-- the row sits on mantle so it reads as chrome, and the selected tab on base so
-- it lines up with the buffer beneath it.
vim.pack.add({
  {
    src = "https://github.com/akinsho/bufferline.nvim",
    name = "bufferline",
    version = "main",
  },
}, { confirm = false, load = true })

vim.opt.showtabline = 2

require("bufferline").setup({
  options = {
    mode = "buffers",
    always_show_bufferline = true,
    -- Counts from the native LSP client, so a file with errors is visible
    -- without opening it.
    diagnostics = "nvim_lsp",
    -- No mouse-oriented chrome: there is no close button to click in a config
    -- driven entirely from the keyboard. "<leader>bd" closes a buffer.
    show_buffer_close_icons = false,
    show_close_icon = false,
    separator_style = "thin",
    -- No "offsets" entry for oil. Offsets reserve room for a sidebar window, and
    -- "<leader>ee" opens the listing in the full window, so the reservation never
    -- has anything to sit beside -- verified: the label simply never rendered.
  },
  highlights = {
    fill = { bg = "#181825" },
    background = { bg = "#181825" },
    buffer_selected = { bg = "#1e1e2e", bold = true },
    separator = { fg = "#181825", bg = "#181825" },
    separator_selected = { fg = "#181825", bg = "#1e1e2e" },
  },
})

-- "[b" / "]b" walk the row, matching "[c" / "]c" on git hunks.
--
-- Deliberately NOT "Shift + h/l", the common binding for this: "H" and "L" are
-- already top-of-screen and bottom-of-screen motions, documented as such in the
-- README's Vim fundamentals. Nor "<Tab>", which the terminal delivers as
-- "Ctrl-i", the jumplist-forward key.
vim.keymap.set("n", "[b", "<cmd>BufferLineCyclePrev<cr>")
vim.keymap.set("n", "]b", "<cmd>BufferLineCycleNext<cr>")

-- Jump straight to a tab by letter, the same idea as the fzf pickers: it labels
-- each tab and waits for the keystroke.
vim.keymap.set("n", "<leader>bb", "<cmd>BufferLinePick<cr>")

-- Reorder the row without changing which buffer is current.
vim.keymap.set("n", "<leader>b,", "<cmd>BufferLineMovePrev<cr>")
vim.keymap.set("n", "<leader>b.", "<cmd>BufferLineMoveNext<cr>")

-- Close the current buffer, or everything except it.
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>")
vim.keymap.set("n", "<leader>bo", "<cmd>BufferLineCloseOthers<cr>")

--------------------------------------------------------------------------------
-- GIT
--------------------------------------------------------------------------------

local icons_git = {
  -- Change type
  added = "✚",
  modified = "○",
  deleted = "✖",
  untracked = "",
}

-- Install gitsigns and use our icons instead of the default ones.
vim.pack.add({
  {
    src = "https://github.com/lewis6991/gitsigns.nvim",
    name = "gitsigns",
    version = "main",
  },
}, { confirm = false, load = true })

require("gitsigns").setup({
  signs = {
    add = { text = icons_git.added },
    change = { text = icons_git.modified },
    delete = { text = icons_git.deleted },
    topdelete = { text = icons_git.deleted },
    changedelete = { text = icons_git.modified },
    untracked = { text = icons_git.untracked },
  },
  signs_staged = {
    add = { text = icons_git.added },
    change = { text = icons_git.deleted },
    delete = { text = icons_git.deleted },
    topdelete = { text = icons_git.deleted },
    changedelete = { text = icons_git.modified },
    untracked = { text = icons_git.untracked },
  },
  preview_config = {
    border = "single",
  },
  on_attach = function(bufnr)
    -- Define keymaps for Git related actions provided by gitsigns.
    local gitsigns = require("gitsigns")

    -- Go to next / previous hunk.
    vim.keymap.set("n", "]c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gitsigns.nav_hunk("next")
      end
    end, { buffer = bufnr })
    vim.keymap.set("n", "[c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gitsigns.nav_hunk("prev")
      end
    end, { buffer = bufnr })

    -- Stage / reset / preview hunk(s).
    vim.keymap.set("n", "<leader>gss", gitsigns.stage_hunk, { buffer = bufnr })
    vim.keymap.set("n", "<leader>gsr", gitsigns.reset_hunk, { buffer = bufnr })
    vim.keymap.set("v", "<leader>gss", function()
      gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { buffer = bufnr })
    vim.keymap.set("v", "<leader>gsr", function()
      gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { buffer = bufnr })
    vim.keymap.set(
      "n",
      "<leader>gsS",
      gitsigns.stage_buffer,
      { buffer = bufnr }
    )
    vim.keymap.set(
      "n",
      "<leader>gsR",
      gitsigns.reset_buffer,
      { buffer = bufnr }
    )
    vim.keymap.set(
      "n",
      "<leader>gsu",
      gitsigns.undo_stage_hunk,
      { buffer = bufnr }
    )
    vim.keymap.set(
      "n",
      "<leader>gsp",
      gitsigns.preview_hunk,
      { buffer = bufnr }
    )

    -- Blame line and show full commit details.
    vim.keymap.set("n", "<leader>gsb", function()
      gitsigns.blame_line({ full = true })
    end, { buffer = bufnr })

    -- Git diff.
    vim.keymap.set("n", "<leader>gsd", gitsigns.diffthis, { buffer = bufnr })

    -- Show hunks in quickfix list.
    vim.keymap.set("n", "<leader>gsq", function()
      gitsigns.setqflist("all")
    end, { buffer = bufnr })

    -- Toggle word diff and deleted lines.
    vim.keymap.set("n", "<leader>gst", function()
      gitsigns.toggle_linehl()
      gitsigns.toggle_word_diff()
      gitsigns.toggle_deleted()
    end, { buffer = bufnr })
  end,
})

-- The "GitDiff <base> <head>" command shows the diff of two branches via
-- gitsigns. If no branches are provided the diff between the current branch
-- and the default branch is shown. It also populates the quickfix list with the
-- hunks.
vim.api.nvim_create_user_command("GitDiff", function(opts)
  local base = ""
  local head = ""

  if #vim.fn.split(opts.args, " ") == 2 then
    base = vim.fn.split(opts.args, " ")[1]
    head = vim.fn.split(opts.args, " ")[2]
  else
    base = vim.fn.system("git branch --show-current"):gsub("[\r\n]", "")
    head = vim.fn
      .system("git remote show origin | sed -n '/HEAD branch/s/.*: //p'")
      :gsub("[\r\n]", "")
  end

  local result = vim.system({ "git", "merge-base", base, head }):wait()
  if result.code ~= 0 then
    return
  end

  local commit = vim.fn.trim(result.stdout)

  local gitsigns = require("gitsigns")
  gitsigns.change_base(commit, true)
  gitsigns.setqflist("all")
end, { nargs = "*" })

vim.keymap.set("n", "<leader>gsD", "<cmd>GitDiff<cr>")

-- Find all merge conflicts in the current Git repository and display them in
-- the quickfix list.
--
-- See: https://github.com/git/git/blob/215033b3ac599432a17d58f18a92b356d98354a9/contrib/git-jump/git-jump#L59
vim.keymap.set("n", "<leader>gfm", function()
  local items = {}
  local files = vim.fn.systemlist(
    "git ls-files -u | perl -pe 's/^.*?\t//' | sort -u | while IFS= read fn; do grep -Hn '^<<<<<<<' \"$fn\"; done"
  )

  for _, file in ipairs(files) do
    local parts = vim.fn.split(file, ":")
    table.insert(items, {
      filename = parts[1],
      lnum = tonumber(parts[2]),
    })
  end

  vim.fn.setqflist({}, " ", { title = "Merge Conflicts", items = items })
  vim.cmd.copen()
end)

-- Keymaps for the Git pickers ("gf" = git find). "enter" opens the file /
-- checks out the branch, "ctrl-q" sends the selection to the quickfix list and
-- "ctrl-s" / "ctrl-v" / "ctrl-t" open in a horizontal / vertical split or a new
-- tab (file pickers only).
vim.keymap.set("n", "<leader>gff", function()
  require("core.picker").git_files()
end)
vim.keymap.set("n", "<leader>gfb", function()
  require("core.picker").git_branches()
end)
vim.keymap.set("n", "<leader>gfd", function()
  require("core.picker").git_diff()
end)
vim.keymap.set("n", "<leader>gfs", function()
  require("core.picker").git_status()
end)
vim.keymap.set("n", "<leader>gfz", function()
  require("core.picker").git_stash()
end)
vim.keymap.set("n", "<leader>gfl", function()
  require("core.picker").git_file_log()
end)
vim.keymap.set("n", "<leader>gfL", function()
  require("core.picker").git_log()
end)

--------------------------------------------------------------------------------
-- MULTICURSOR
--------------------------------------------------------------------------------

vim.pack.add({
  {
    src = "https://github.com/jake-stewart/multicursor.nvim",
    name = "multicursor",
    version = "main",
  },
}, { confirm = false, load = true })

vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup(
    "lazy-load-multicursor",
    { clear = true }
  ),
  once = true,
  callback = function()
    local mc = require("multicursor-nvim")
    mc.setup()

    -- Define keymaps for multicursor operations. A new cursor can be added
    -- using "Ctrl + k" / "Ctrl + j" for the line above / below, using
    -- "Ctrl + n" for the next word under the cursor "Ctrl + a" for all
    -- occurrences of the word under the cursor or using "Ctrl = m" for all
    -- provided matches.
    vim.keymap.set("n", "<c-k>", function()
      mc.addCursor("k")
    end)
    vim.keymap.set("n", "<c-j>", function()
      mc.addCursor("j")
    end)
    vim.keymap.set({ "n", "x" }, "<c-n>", function()
      mc.addCursor("*")
    end)
    vim.keymap.set({ "n", "x" }, "<c-a>", mc.matchAllAddCursors)
    vim.keymap.set("x", "<c-m>", mc.matchCursors)

    mc.addKeymapLayer(function(layerSet)
      layerSet("n", "<esc>", function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        else
          mc.clearCursors()
        end
      end)
    end)

    -- Customize highlight groups for multicursor.
    local hl = vim.api.nvim_set_hl
    hl(0, "MultiCursorCursor", { link = "Cursor" })
    hl(0, "MultiCursorVisual", { link = "Visual" })
    hl(0, "MultiCursorSign", { link = "SignColumn" })
    hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
    hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
    hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
  end,
})
