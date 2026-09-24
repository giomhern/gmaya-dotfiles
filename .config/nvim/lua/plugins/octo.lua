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
      use_local_fs = true,
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
        "<cmd>Octo review<cr>",
        desc = "Review current pull request",
      },
      {
        "<leader>ghn",
        "<cmd>Octo notification list<cr>",
        desc = "List GitHub notifications",
      },
    },
  },
}
