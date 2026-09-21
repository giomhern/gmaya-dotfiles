return {
  {
    "akinsho/bufferline.nvim",
    branch = "main",
    dependencies = { "echasnovski/mini.icons" },
    lazy = false,
    config = function()
      local buffers = require("core.buffers")
      -- One tab per open buffer along the top. Buffers, not tabpages: Neovim's own
      -- ":tabs" are separate window layouts, and this config barely uses them, so the
      -- row tracks what is actually open. Icons come from the mini.icons devicons
      -- mock set up in the EXPLORER section above, which is why this block has to
      -- follow it.
      --
      -- Bufferline derives its palette from the colorscheme. Only the fills are
      -- pinned below, to
      -- the same base / mantle split the fzf picker uses:
      -- the row sits on mantle so it reads as chrome, and the selected tab on base so
      -- it lines up with the buffer beneath it.
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
          offsets = {
            {
              filetype = "neo-tree",
              text = " Explorer",
              text_align = "left",
              highlight = "Directory",
            },
          },
        },
        highlights = {
          fill = { bg = "#e6e9ef" },
          background = { bg = "#e6e9ef" },
          buffer_selected = { bg = "#eff1f5", bold = true },
          separator = { fg = "#e6e9ef", bg = "#e6e9ef" },
          separator_selected = { fg = "#e6e9ef", bg = "#eff1f5" },
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
      vim.keymap.set("n", "<leader>bb", "<cmd>BufferLinePick<cr>", {
        desc = "Pick buffer",
      })

      -- Reorder the row without changing which buffer is current.
      vim.keymap.set("n", "<leader>b,", "<cmd>BufferLineMovePrev<cr>", {
        desc = "Move buffer left",
      })
      vim.keymap.set("n", "<leader>b.", "<cmd>BufferLineMoveNext<cr>", {
        desc = "Move buffer right",
      })

      local function show_explorer_fullscreen()
        require("neo-tree.command").execute({
          action = "close",
          source = "filesystem",
        })
        pcall(vim.cmd, "silent only")
        require("neo-tree.command").execute({
          action = "focus",
          source = "filesystem",
          position = "current",
          dir = vim.fn.getcwd(),
        })
      end

      -- Close the current file without letting Neovim invent a [No Name] fallback.
      -- Select the next open file first; when this was the last one, replace its
      -- window with a full-screen Neo-tree and then delete the hidden file buffer.
      vim.keymap.set("n", "<leader>bd", function()
        local current = vim.api.nvim_get_current_buf()
        if not buffers.is_file(current) then
          vim.notify(
            "The current window is not a file buffer",
            vim.log.levels.INFO
          )
          return
        end
        if vim.bo[current].modified then
          vim.notify(
            "Write or discard changes before closing this buffer",
            vim.log.levels.WARN
          )
          return
        end

        local file_buffers = buffers.files()
        if #file_buffers > 1 then
          local current_index = 1
          for index, buf in ipairs(file_buffers) do
            if buf == current then
              current_index = index
              break
            end
          end
          local next_buf = file_buffers[(current_index % #file_buffers) + 1]
          vim.api.nvim_win_set_buf(0, next_buf)
          vim.api.nvim_buf_delete(current, {})
          return
        end

        show_explorer_fullscreen()
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(current) then
            vim.api.nvim_buf_delete(current, {})
          end
          buffers.remove_empty_unnamed()
        end)
      end, { desc = "Close file and preserve explorer fallback" })

      -- Close everything except the current buffer.
      vim.keymap.set("n", "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", {
        desc = "Close other buffers",
      })
    end,
  },
}
