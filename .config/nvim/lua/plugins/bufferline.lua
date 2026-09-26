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
      -- pinned below: the row shares Neo-tree's mantle canvas, while the
      -- selected tab uses the editor base beneath it.
      local function update_visibility()
        vim.opt.showtabline = #buffers.files() > 0 and 2 or 0
      end
      vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete", "BufEnter" }, {
        desc = "Show buffer tabs only when file buffers are open",
        callback = function()
          vim.schedule(update_visibility)
        end,
      })
      vim.api.nvim_create_autocmd("VimEnter", {
        desc = "Set initial buffer-tab visibility",
        callback = update_visibility,
      })
      update_visibility()

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
              highlight = "NeoTreeNormal",
            },
          },
        },
        highlights = {
          fill = { bg = "#f8f0e7" },
          background = { bg = "#f8f0e7" },
          buffer_selected = { bg = "#faf4ed", bold = true },
          separator = { fg = "#f8f0e7", bg = "#f8f0e7" },
          separator_selected = { fg = "#f8f0e7", bg = "#faf4ed" },
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

      local function normal_windows()
        local result = {}
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if vim.api.nvim_win_get_config(win).relative == "" then
            result[#result + 1] = win
          end
        end
        return result
      end

      local function delete_if_hidden(buf)
        if vim.api.nvim_buf_is_valid(buf) and #vim.fn.win_findbuf(buf) == 0 then
          vim.api.nvim_buf_delete(buf, {})
        end
      end

      local function show_explorer_fullscreen(closing_buf)
        local current_win = vim.api.nvim_get_current_win()
        local kept_window = false
        if buffers.neo_tree_window() then
          require("neo-tree.command").execute({
            action = "close",
            source = "filesystem",
          })
        end
        for _, win in ipairs(normal_windows()) do
          if win ~= current_win then
            local buf = vim.api.nvim_win_get_buf(win)
            if
              buf == closing_buf
              or buffers.is_empty_unnamed(buf)
              or vim.bo[buf].filetype == "neo-tree"
            then
              vim.api.nvim_win_close(win, false)
            else
              -- Keep modified scratch, terminals, and other special windows.
              kept_window = true
            end
          end
        end
        require("neo-tree.command").execute({
          action = "focus",
          source = "filesystem",
          position = "current",
          dir = vim.fn.getcwd(),
        })
        if kept_window then
          vim.notify(
            "Kept other non-file windows open beside Neo-tree",
            vim.log.levels.INFO
          )
        end
      end

      local function close_empty_unnamed(buf)
        local win = vim.api.nvim_get_current_win()
        local files = buffers.files()
        if #files > 0 then
          local file_win
          for _, candidate in ipairs(normal_windows()) do
            if
              candidate ~= win
              and buffers.is_file(vim.api.nvim_win_get_buf(candidate))
            then
              file_win = candidate
              break
            end
          end
          local other_tab_file
          if not file_win then
            for _, candidate in ipairs(vim.api.nvim_list_wins()) do
              if buffers.is_file(vim.api.nvim_win_get_buf(candidate)) then
                other_tab_file = candidate
                break
              end
            end
          end
          if file_win then
            vim.api.nvim_set_current_win(file_win)
            vim.api.nvim_win_close(win, false)
          elseif other_tab_file then
            if #normal_windows() == 1 then
              vim.cmd.tabclose()
            else
              vim.api.nvim_win_close(win, false)
            end
            vim.api.nvim_set_current_win(other_tab_file)
          else
            local special_sibling = false
            for _, candidate in ipairs(normal_windows()) do
              local candidate_buf = vim.api.nvim_win_get_buf(candidate)
              if
                candidate ~= win
                and not buffers.is_empty_unnamed(candidate_buf)
                and vim.bo[candidate_buf].filetype ~= "neo-tree"
              then
                special_sibling = true
                break
              end
            end
            if special_sibling then
              -- Do not replace an Octo/Diffview/scratch pane with a file.
              vim.api.nvim_win_close(win, false)
              vim.cmd("tab sbuffer " .. files[1])
            else
              vim.api.nvim_win_set_buf(win, files[1])
            end
          end
        else
          if #normal_windows() == 1 and #vim.api.nvim_list_tabpages() > 1 then
            vim.cmd.tabclose()
            if vim.bo.filetype ~= "neo-tree" then
              show_explorer_fullscreen(buf)
            end
          else
            show_explorer_fullscreen(buf)
          end
        end
        -- A buffer displayed in another tab stays available there.
        delete_if_hidden(buf)
      end

      -- Close the current file or disposable empty unnamed buffer without
      -- letting Neovim invent another [No Name] fallback.
      -- Select the next open file first; when this was the last one, replace its
      -- window with a full-screen Neo-tree and then delete the hidden file buffer.
      vim.keymap.set("n", "<leader>bd", function()
        local current = vim.api.nvim_get_current_buf()
        if buffers.is_empty_unnamed(current) then
          close_empty_unnamed(current)
          return
        end
        if not buffers.is_file(current) then
          if
            vim.bo[current].buftype == ""
            and vim.api.nvim_buf_get_name(current) == ""
          then
            vim.notify(
              "Unnamed buffer has changes; save it with :saveas <path>",
              vim.log.levels.WARN
            )
          else
            vim.notify(
              "The current window is not a file buffer",
              vim.log.levels.INFO
            )
          end
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
          -- A file can be visible in several splits or tabpages. Replace every
          -- view before deleting it so Neovim does not close those windows.
          for _, win in ipairs(vim.fn.win_findbuf(current)) do
            vim.api.nvim_win_set_buf(win, next_buf)
          end
          vim.api.nvim_buf_delete(current, {})
          return
        end

        -- Neo-tree may replace the file window asynchronously. Delete the
        -- file only once it is actually hidden, never while a window shows it.
        vim.api.nvim_create_autocmd("BufHidden", {
          buffer = current,
          once = true,
          callback = function()
            vim.schedule(function()
              delete_if_hidden(current)
              buffers.remove_empty_unnamed()
            end)
          end,
        })
        show_explorer_fullscreen(current)
      end, { desc = "Close file or empty unnamed buffer" })

      -- Close everything except the current buffer.
      vim.keymap.set("n", "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", {
        desc = "Close other buffers",
      })
    end,
  },
}
