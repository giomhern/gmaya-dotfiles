return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    opts = {
      -- Tab accepts a completion, advances through snippet placeholders, or
      -- falls back to normal indentation depending on the current context.
      keymap = {
        preset = "super-tab",
        ["<C-s>"] = { "show_signature", "hide_signature", "fallback" },
      },
      completion = {
        list = {
          selection = {
            preselect = false,
            auto_insert = false,
          },
        },
        menu = {
          max_height = 10,
          draw = {
            -- Text kind names avoid mixing Material and Font Awesome glyphs with
            -- the Octicon policy used by the rest of the interface.
            columns = {
              { "label", "label_description", gap = 1 },
              { "kind" },
            },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 300,
        },
        -- Copilot owns inline ghost text through Neovim's LSP client.
        ghost_text = { enabled = false },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      snippets = { preset = "default" },
      signature = { enabled = true },
      fuzzy = { implementation = "prefer_rust_with_warning" },
      -- Keep the existing command-line wildmenu behavior independent from Blink.
      cmdline = { enabled = false },
    },
    opts_extend = { "sources.default" },
  },
}
