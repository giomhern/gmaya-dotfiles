return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      cmdline = {
        format = {
          cmdline = { pattern = "^:", icon = ":", lang = "vim" },
          search_down = {
            kind = "search",
            pattern = "^/",
            icon = "/",
            lang = "regex",
          },
          search_up = {
            kind = "search",
            pattern = "^%?",
            icon = "?",
            lang = "regex",
          },
          filter = { pattern = "^:%s*!", icon = "!", lang = "bash" },
          lua = {
            pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" },
            icon = "Lua",
            lang = "lua",
          },
          help = { pattern = "^:%s*he?l?p?%s+", icon = "Help" },
        },
      },
      messages = {
        view = "mini",
        view_error = "mini",
        view_warn = "mini",
      },
      popupmenu = {
        backend = "nui",
        kind_icons = false,
      },
      lsp = {
        -- init.lua already turns LSP progress into terminal progress. Letting
        -- Noice handle it as well would display every update twice.
        progress = { enabled = false },
        documentation = {
          opts = { border = { style = "single" } },
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
      routes = {
        -- Preserve progress history and Ghostty's progress indicator without
        -- drawing jdtls/build updates over the editor.
        {
          filter = { event = "msg_show", kind = "progress" },
          opts = { skip = true },
        },
      },
    },
    keys = {
      { "<leader>nh", "<cmd>Noice history<cr>", desc = "Message history" },
      { "<leader>nl", "<cmd>Noice last<cr>", desc = "Last message" },
      { "<leader>ne", "<cmd>Noice errors<cr>", desc = "Message errors" },
      { "<leader>nd", "<cmd>Noice dismiss<cr>", desc = "Dismiss messages" },
    },
  },
}
