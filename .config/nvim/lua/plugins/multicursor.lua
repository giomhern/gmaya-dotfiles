return {
  {
    "jake-stewart/multicursor.nvim",
    branch = "main",
    lazy = false,
    config = function()
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
    end,
  },
}
