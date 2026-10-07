return {
  {
    "nvim-tree/nvim-web-devicons",
    branch = "master",
    lazy = false,
    config = function()
      require("nvim-web-devicons").setup()
    end,
  },
}
