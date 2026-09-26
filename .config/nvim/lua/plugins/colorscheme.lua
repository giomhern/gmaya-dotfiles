return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    dependencies = {
      { "folke/tokyonight.nvim", lazy = false },
      { "rose-pine/neovim", name = "rose-pine", lazy = false },
    },
    lazy = false,
    config = function()
      -- Set borders for floating windows, popup menus and the command line completion
      -- menu. Also set a custom background color for the popup menu and a border
      -- color.
      vim.opt.winborder = "single"
      vim.opt.pumborder = "single"

      -- The selected family is changed by theme.sh. Both setup paths normalize their
      -- palettes so the custom picker, explorer, and statusline styling stays shared.
      local selected_theme = "rose-pine-dawn"

      local function custom_theme_highlights(colors)
        local popup_bg = colors.mantle
        local highlights = {
          -- Popups use the same canvas as Neo-tree in every theme.
          NormalFloat = { fg = colors.text, bg = popup_bg },
          FloatBorder = { fg = colors.blue, bg = popup_bg },
          FloatTitle = { fg = colors.blue, bg = popup_bg, bold = true },
          WhichKeyNormal = { fg = colors.text, bg = popup_bg },
          WhichKeyFloat = { fg = colors.text, bg = popup_bg },
          WhichKeyBorder = { fg = colors.blue, bg = popup_bg },
          WhichKeyTitle = { fg = colors.blue, bg = popup_bg, bold = true },

          Pmenu = { bg = popup_bg },
          PmenuBorder = { bg = popup_bg, fg = colors.blue },
          BlinkCmpMenu = { link = "Pmenu" },
          BlinkCmpMenuBorder = { bg = popup_bg, fg = colors.blue },
          BlinkCmpDoc = { fg = colors.text, bg = popup_bg },
          BlinkCmpDocBorder = { fg = colors.blue, bg = popup_bg },
          BlinkCmpDocSeparator = { fg = colors.overlay1, bg = popup_bg },
          BlinkCmpSignatureHelp = { fg = colors.text, bg = popup_bg },
          BlinkCmpSignatureHelpBorder = {
            fg = colors.blue,
            bg = popup_bg,
          },
          NoicePopupmenuBorder = { fg = colors.blue, bg = popup_bg },
          NoiceCmdlineIcon = {
            fg = colors.blue,
            bg = popup_bg,
            italic = false,
          },
          NoiceCmdlineIconSearch = {
            fg = colors.yellow,
            bg = popup_bg,
            italic = false,
          },
          NoiceCmdlinePopup = { fg = colors.text, bg = popup_bg },
          NoiceCmdlinePopupBorder = { fg = colors.blue, bg = popup_bg },
          NoiceCmdlinePopupBorderSearch = {
            fg = colors.yellow,
            bg = popup_bg,
          },
          NoiceCmdlinePopupTitle = {
            fg = colors.blue,
            bg = popup_bg,
            bold = true,
          },
          NoiceCmdlinePopupTitleSearch = {
            fg = colors.yellow,
            bg = popup_bg,
            bold = true,
          },
          NoiceConfirmBorder = { fg = colors.blue, bg = popup_bg },

          -- Noice command line uses dedicated groups so its defaults cannot
          -- reintroduce diagnostic italics or a mismatched popup surface.
          GmayaCmdlinePopup = { fg = colors.text, bg = popup_bg },
          GmayaCmdlineBorder = { fg = colors.blue, bg = popup_bg },
          GmayaCmdlineTitle = {
            fg = colors.blue,
            bg = popup_bg,
            bold = true,
          },
          GmayaCmdlineIcon = {
            fg = colors.blue,
            bg = popup_bg,
            italic = false,
          },

          -- Octo's defaults use GitHub's fixed palette. Define its groups here
          -- first so Octo preserves the active Catppuccin/Tokyo Night palette.
          OctoGreen = { fg = colors.green },
          OctoRed = { fg = colors.red },
          OctoPurple = { fg = colors.mauve },
          OctoYellow = { fg = colors.yellow },
          OctoBlue = { fg = colors.blue },
          OctoGrey = { fg = colors.overlay1 },
          OctoGreenFloat = { fg = colors.green, bg = popup_bg },
          OctoRedFloat = { fg = colors.red, bg = popup_bg },
          OctoPurpleFloat = { fg = colors.mauve, bg = popup_bg },
          OctoYellowFloat = { fg = colors.yellow, bg = popup_bg },
          OctoBlueFloat = { fg = colors.blue, bg = popup_bg },
          OctoGreyFloat = { fg = colors.overlay1, bg = popup_bg },
          OctoBubbleGreen = { fg = colors.base, bg = colors.green },
          OctoBubbleRed = { fg = colors.base, bg = colors.red },
          OctoBubblePurple = { fg = colors.base, bg = colors.mauve },
          OctoBubbleYellow = { fg = colors.base, bg = colors.yellow },
          OctoBubbleBlue = { fg = colors.base, bg = colors.blue },
          OctoBubbleGrey = { fg = colors.text, bg = colors.overlay1 },
          OctoViewer = { fg = colors.base, bg = colors.blue },
          OctoReviewDiffAddText = { fg = colors.text, bg = colors.green },
          OctoReviewDiffDeleteText = { fg = colors.text, bg = colors.red },

          -- Picker (see "lua/core/picker.lua").
          PickerNormal = { fg = colors.text, bg = popup_bg },
          PickerBorder = { bg = popup_bg, fg = colors.blue },

          -- Explorer marks (see "lua/core/explorer.lua").
          ExplorerMark = { fg = colors.rosewater },
          ExplorerMarkLine = { bg = colors.surface0 },

          -- Neo-tree sidebar.
          NeoTreeNormal = { bg = popup_bg },
          NeoTreeNormalNC = { bg = popup_bg },
          NeoTreeEndOfBuffer = { bg = popup_bg },
          NeoTreeFloatNormal = { fg = colors.text, bg = popup_bg },
          NeoTreeFloatBorder = { fg = colors.blue, bg = popup_bg },
          NeoTreeFloatTitle = {
            fg = colors.blue,
            bg = popup_bg,
            bold = true,
          },
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

      if selected_theme:match("^tokyonight%-") then
        local style = selected_theme == "tokyonight-day" and "day" or "moon"
        require("tokyonight").setup({
          style = style,
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
        vim.cmd.colorscheme(selected_theme)
      elseif selected_theme:match("^rose%-pine") then
        local variant = selected_theme == "rose-pine-dawn" and "dawn" or "main"
        require("rose-pine").setup({ variant = variant })
        vim.cmd.colorscheme("rose-pine-" .. variant)
        local rose = require("rose-pine.palette")
        local palette = {
          mantle = rose._nc,
          base = rose.base,
          surface0 = rose.highlight_low,
          overlay1 = rose.muted,
          text = rose.text,
          rosewater = rose.rose,
          blue = rose.foam,
          green = rose.leaf,
          mauve = rose.iris,
          red = rose.love,
          peach = rose.rose,
          yellow = rose.gold,
          sky = rose.foam,
          teal = rose.pine,
        }
        for group, spec in pairs(custom_theme_highlights(palette)) do
          vim.api.nvim_set_hl(0, group, spec)
        end
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
