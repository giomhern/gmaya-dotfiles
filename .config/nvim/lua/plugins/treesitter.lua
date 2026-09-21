return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    config = function()
      -- Install the nvim-treesitter plugin and ensure that some parsers are always
      -- installed. We also allow auto installing of additional parsers.
      require("nvim-treesitter").setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      local ts_parsers = {
        "bash",
        "css",
        "dart",
        "diff",
        "dockerfile",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "go",
        "gomod",
        "gosum",
        "html",
        "javascript",
        "json",
        "lua",
        "make",
        "markdown",
        "markdown_inline",
        "python",
        "regex",
        "rust",
        "sql",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "yaml",
        "zig",
      }

      local ts = require("nvim-treesitter")
      vim.schedule(function()
        ts.install(ts_parsers)
      end)

      -- Enable treesitter highlighting and indents.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup(
          "nvim-treesitter-enable-highlighting-and-indents-handler",
          { clear = true }
        ),
        callback = function(event)
          local filetype = event.match
          local lang = vim.treesitter.language.get_lang(filetype)
          if lang and vim.treesitter.language.add(lang) then
            if vim.treesitter.query.get(filetype, "indents") then
              vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
            if vim.treesitter.query.get(filetype, "folds") then
              vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
              vim.wo.foldmethod = "expr"
            end
            vim.treesitter.start()
          end
        end,
      })
    end,
  },
}
