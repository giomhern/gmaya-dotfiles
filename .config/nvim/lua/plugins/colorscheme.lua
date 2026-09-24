return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    dependencies = { { "folke/tokyonight.nvim", lazy = false } },
    lazy = false,
    config = function()
      -- Set borders for floating windows, popup menus and the command line completion
      -- menu. Also set a custom background color for the popup menu and a border
      -- color.
      vim.opt.winborder = "single"
      vim.opt.pumborder = "single"

      -- The selected family is changed by theme.sh. Both setup paths normalize their
      -- palettes so the custom picker, explorer, and statusline styling stays shared.
      local selected_theme = "mocha"

      local function custom_theme_highlights(colors)
        local highlights = {
          Pmenu = { bg = colors.mantle },
          PmenuBorder = { bg = colors.mantle, fg = colors.blue },

          -- Picker (see "lua/core/picker.lua").
          PickerNormal = { bg = colors.base },
          PickerBorder = { bg = colors.base, fg = colors.blue },

          -- Explorer marks (see "lua/core/explorer.lua").
          ExplorerMark = { fg = colors.rosewater },
          ExplorerMarkLine = { bg = colors.surface0 },

          -- Neo-tree sidebar.
          NeoTreeNormal = { bg = colors.mantle },
          NeoTreeNormalNC = { bg = colors.mantle },
          NeoTreeEndOfBuffer = { bg = colors.mantle },
          NeoTreeWinSeparator = { fg = colors.surface0, bg = colors.mantle },
          NeoTreeDirectoryName = { fg = colors.blue },
          NeoTreeDirectoryIcon = { fg = colors.blue },
          NeoTreeRootName = { fg = colors.mauve, bold = true },

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
          highlights["StatuslineB_" .. key] =
            { fg = color, bg = colors.surface0 }
          highlights["StatuslineSepAB_" .. key] =
            { fg = color, bg = colors.surface0 }
          highlights["StatuslineSepYZ_" .. key] =
            { fg = color, bg = colors.surface0 }
          highlights["StatuslineSepAC_" .. key] =
            { fg = color, bg = colors.mantle }
        end

        return highlights
      end

      if selected_theme == "tokyonight-moon" then
        require("tokyonight").setup({
          style = "moon",
          on_highlights = function(highlights, palette)
            local colors = {
              mantle = palette.bg_dark,
              base = palette.bg,
              surface0 = palette.bg_highlight,
              overlay1 = palette.comment,
              text = palette.fg,
              rosewater = palette.purple,
              blue = palette.blue,
              green = palette.green,
              mauve = palette.magenta,
              red = palette.red,
              peach = palette.orange,
              yellow = palette.yellow,
              sky = palette.cyan,
              teal = palette.teal,
            }
            for group, spec in pairs(custom_theme_highlights(colors)) do
              highlights[group] = spec
            end
          end,
        })
        vim.cmd.colorscheme("tokyonight-moon")
      else
        require("catppuccin").setup({
          flavour = selected_theme,
          default_integrations = false,
          integrations = {
            blink_cmp = true,
            diffview = true,
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
              inlay_hints = { background = true },
            },
            treesitter = true,
            noice = true,
            which_key = true,
          },
          custom_highlights = custom_theme_highlights,
        })
        vim.cmd.colorscheme("catppuccin-nvim")
      end
    end,
  },
}
