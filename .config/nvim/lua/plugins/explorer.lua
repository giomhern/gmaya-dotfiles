return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      { "nvim-tree/nvim-web-devicons", branch = "master" },
    },
    lazy = false,
    config = function()
      local icons = require("core.icons")
      -- Neo-tree is the single project and directory explorer. Keeping one explorer
      -- makes "nvim .", ":e path/", and the sidebar use the same keys and behavior.
      local buffers = require("core.buffers")
      local deleting_windows = {}

      require("neo-tree").setup({
        close_if_last_window = false,
        popup_border_style = "single",
        log_level = vim.log.levels.WARN,
        enable_git_status = true,
        enable_diagnostics = true,
        event_handlers = {
          {
            event = "before_render",
            handler = function(state)
              -- The sidebar title lives in bufferline; the full-screen tree
              -- still needs its own title when there are no file tabs.
              local hide_root = state.current_position == "left"
              require("neo-tree").config.hide_root_node = hide_root
              -- Hidden roots have no row to restore the cursor to.
              if hide_root and state.position.node_id == state.path then
                state.position.node_id = nil
              end
            end,
          },
          {
            event = "before_file_delete",
            handler = function(path)
              local windows = {}
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                local buf = vim.api.nvim_win_get_buf(win)
                if vim.api.nvim_buf_get_name(buf) == path then
                  windows[#windows + 1] = win
                end
              end
              deleting_windows[path] = windows
            end,
          },
          {
            event = "file_deleted",
            handler = function(path)
              local windows = deleting_windows[path] or {}
              deleting_windows[path] = nil
              vim.schedule(function()
                buffers.recover_deleted_file_windows(windows)
              end)
            end,
          },
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
          position = "left",
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
          components = {
            name = function(config, node, state)
              local result = require("neo-tree.sources.common.components").name(
                config,
                node,
                state
              )
              if node:get_depth() == 1 and node.type == "directory" then
                result.text = "/"
                  .. vim.fn.fnamemodify(node.path, ":t")
                  .. result.text:sub(#node.name + 1)
              end
              return result
            end,
          },
          -- Open directory buffers on BufEnter instead of Neo-tree's debounced
          -- netrw hijack, which briefly exposes the directory buffer at startup.
          hijack_netrw_behavior = "disabled",
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

      -- Neo-tree normally disables netrw when its hijack is enabled. Keep
      -- netrw from taking the buffer while we open the tree directly.
      vim.cmd("silent! autocmd! FileExplorer *")
      local directory_group = vim.api.nvim_create_augroup(
        "gmaya-neo-tree-directory",
        { clear = true }
      )
      vim.api.nvim_create_autocmd("BufEnter", {
        group = directory_group,
        desc = "Open directories directly in Neo-tree",
        callback = function(ev)
          local path = vim.api.nvim_buf_get_name(ev.buf)
          local stat = path ~= "" and vim.uv.fs_stat(path)
          if not stat or stat.type ~= "directory" then
            return
          end

          local win = vim.api.nvim_get_current_win()
          if vim.api.nvim_win_get_buf(win) ~= ev.buf then
            return
          end
          require("neo-tree.command").execute({
            action = "focus",
            source = "filesystem",
            position = "current",
            dir = path,
          })
          vim.schedule(function()
            if
              vim.api.nvim_buf_is_valid(ev.buf)
              and #vim.fn.win_findbuf(ev.buf) == 0
            then
              vim.api.nvim_buf_delete(ev.buf, { force = true })
            end
          end)
        end,
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
          position = #buffers.files() > 0 and "left" or "current",
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
          position = #buffers.files() > 0 and "left" or "current",
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
      vim.keymap.set("n", "<leader>ew", "<cmd>noautocmd write ++p<cr>", {
        desc = "Write and create parent directories",
      })
    end,
  },
}
