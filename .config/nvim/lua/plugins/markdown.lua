return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    branch = "main",
    dependencies = { "echasnovski/mini.icons" },
    lazy = false,
    config = function()
      -- Render Markdown in Neovim without starting a browser or preview server.
      require("render-markdown").setup({
        enabled = false,
        file_types = { "markdown", "markdown.mdx" },
      })

      local function preview_pdf()
        local path = vim.api.nvim_buf_get_name(0)
        if path == "" or vim.fn.filereadable(path) ~= 1 then
          vim.notify("Save the PDF before previewing it", vim.log.levels.WARN)
          return
        end

        vim.system({ "open", "-a", "Preview", path }, {}, function(result)
          if result.code ~= 0 then
            vim.schedule(function()
              vim.notify("Could not open PDF in Preview", vim.log.levels.ERROR)
            end)
          end
        end)
      end

      local function preview_current_file()
        local filetype = vim.bo.filetype
        local extension =
          vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":e"):lower()

        if filetype == "markdown" or filetype == "markdown.mdx" then
          require("render-markdown").buf_toggle()
        elseif filetype == "pdf" or extension == "pdf" then
          preview_pdf()
        else
          vim.notify(
            "Preview is available for Markdown and PDF buffers",
            vim.log.levels.INFO
          )
        end
      end

      vim.api.nvim_create_user_command("PreviewFile", preview_current_file, {
        desc = "Preview the current Markdown or PDF file",
      })
      vim.keymap.set("n", "<leader>pv", preview_current_file, {
        desc = "Preview Markdown or PDF",
      })
    end,
  },
}
