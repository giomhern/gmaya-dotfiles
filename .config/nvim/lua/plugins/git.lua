return {
  {
    "lewis6991/gitsigns.nvim",
    branch = "main",
    lazy = false,
    config = function()
      local icons = require("core.icons")
      local icons_git = {
        -- Change type
        added = icons.git.added,
        modified = icons.git.modified,
        deleted = icons.git.deleted,
        untracked = icons.git.untracked,
      }

      -- Install gitsigns and use our icons instead of the default ones.
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
          vim.keymap.set(
            "n",
            "<leader>gss",
            gitsigns.stage_hunk,
            { buffer = bufnr }
          )
          vim.keymap.set(
            "n",
            "<leader>gsr",
            gitsigns.reset_hunk,
            { buffer = bufnr }
          )
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
          vim.keymap.set(
            "n",
            "<leader>gsd",
            gitsigns.diffthis,
            { buffer = bufnr }
          )

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
    end,
  },
}
