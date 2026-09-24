return {
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      picker = "default",
      enable_builtin = true,
      default_remote = { "upstream", "origin" },
      -- Review any PR from its GitHub revision without a checkout prompt.
      use_local_fs = false,
      file_panel = {
        icons = false,
      },
      reviews = {
        auto_show_threads = true,
        focus = "right",
        show_virtual_text = true,
      },
    },
    keys = {
      {
        "<leader>ghp",
        "<cmd>Octo pr list<cr>",
        desc = "List pull requests",
      },
      {
        "<leader>ghr",
        "<cmd>Octo review browse<cr>",
        desc = "Browse pull request diff and threads (read-only)",
      },
      {
        "<leader>ghs",
        "<cmd>Octo review<cr>",
        desc = "Start or resume a pending PR review",
      },
      {
        "<leader>ghc",
        "<cmd>Octo review close<cr>",
        desc = "Close pull request review",
      },
      {
        "<leader>ghn",
        "<cmd>Octo notification list<cr>",
        desc = "List GitHub notifications",
      },
    },
  },
}
