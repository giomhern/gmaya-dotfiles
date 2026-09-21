return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      { "echasnovski/mini.icons", branch = "main" },
    },
    lazy = false,
    config = function()
      local icons = require("core.icons")
      -- Neo-tree is the single project and directory explorer. Keeping one explorer
      -- makes "nvim .", ":e path/", and the sidebar use the same keys and behavior.
      local buffers = require("core.buffers")

      require("neo-tree").setup({
        close_if_last_window = false,
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,
        event_handlers = {
          {
            event = "neo_tree_window_after_open",
            handler = function()
              vim.schedule(function()
                buffers.remove_empty_unnamed()
              end)
            end,
          },
        },
        default_component_configs = {
          indent = {
            with_expanders = true,
            expander_collapsed = icons.tree.collapsed,
            expander_expanded = icons.tree.expanded,
            with_markers = true,
            indent_marker = "│",
            last_indent_marker = "└",
          },
          git_status = {
            symbols = {
              added = icons.git.added,
              modified = icons.git.modified,
              deleted = icons.git.deleted,
              renamed = icons.git.renamed,
              untracked = icons.git.untracked,
              ignored = icons.git.ignored,
              unstaged = icons.git.modified,
              staged = icons.git.staged,
              conflict = icons.git.conflict,
            },
          },
        },
        window = {
          position = "right",
          width = 34,
          mappings = {
            -- Leader is Space, so do not let Neo-tree consume it before mappings such
            -- as <leader>ee can complete.
            ["<space>"] = "none",
            ["h"] = "close_node",
            ["l"] = "open",
            ["P"] = {
              "toggle_preview",
              config = { use_float = true },
            },
          },
        },
        filesystem = {
          hijack_netrw_behavior = "open_current",
          follow_current_file = {
            enabled = true,
            leave_dirs_open = false,
          },
          filtered_items = {
            visible = false,
            hide_dotfiles = false,
            hide_gitignored = true,
            never_show = { ".git" },
          },
        },
      })

      local function current_file_or_cwd()
        if vim.bo.filetype == "neo-tree" then
          return vim.fn.getcwd()
        end
        local bufname = vim.api.nvim_buf_get_name(0)
        if bufname == "" then
          return vim.fn.getcwd()
        end
        return bufname
      end

      vim.keymap.set("n", "<leader>ee", function()
        local win = buffers.neo_tree_window()
        if win then
          vim.api.nvim_set_current_win(win)
          return
        end
        require("neo-tree.command").execute({
          action = "focus",
          source = "filesystem",
          position = #buffers.files() > 0 and "right" or "current",
          reveal_file = current_file_or_cwd(),
          reveal_force_cwd = true,
        })
      end, { desc = "Focus explorer and reveal current file" })

      vim.keymap.set("n", "<leader>et", function()
        if buffers.neo_tree_window() then
          if #buffers.files() == 0 then
            return
          end
          require("neo-tree.command").execute({
            action = "close",
            source = "filesystem",
          })
          return
        end
        require("neo-tree.command").execute({
          action = "focus",
          source = "filesystem",
          position = #buffers.files() > 0 and "right" or "current",
          reveal_file = current_file_or_cwd(),
          reveal_force_cwd = true,
        })
      end, { desc = "Toggle explorer" })

      vim.keymap.set("n", "<leader>ec", function()
        if buffers.neo_tree_window() and #buffers.files() > 0 then
          require("neo-tree.command").execute({
            action = "close",
            source = "filesystem",
          })
        end
      end, { desc = "Close explorer" })

      -- Keymap to save a file without running any auto commands and with creating
      -- directories.
      vim.keymap.set("n", "<leader>ew", "<cmd>noautocmd write ++p<cr>")
    end,
  },
}
