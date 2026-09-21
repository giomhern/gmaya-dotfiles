return {
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewFileHistory",
    },
    opts = function()
      local icons = require("core.icons")
      return {
        enhanced_diff_hl = true,
        use_icons = false,
        signs = {
          fold_closed = icons.tree.collapsed,
          fold_open = icons.tree.expanded,
          done = icons.git.staged,
        },
        view = {
          default = { winbar_info = true },
          merge_tool = { winbar_info = true },
          file_history = { winbar_info = true },
        },
      }
    end,
    keys = {
      {
        "<leader>gdo",
        "<cmd>DiffviewOpen<cr>",
        desc = "Open working-tree review",
      },
      { "<leader>gdc", "<cmd>DiffviewClose<cr>", desc = "Close diff review" },
      {
        "<leader>gdf",
        "<cmd>DiffviewFileHistory %<cr>",
        desc = "Current-file history",
      },
      {
        "<leader>gdh",
        "<cmd>DiffviewFileHistory<cr>",
        desc = "Repository history",
      },
    },
  },
}
