return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 250,
      icons = {
        -- Which-key's automatic mapping icons mix several Nerd Font families.
        -- Keep the popup textual so semantic icons remain the Octicons defined in
        -- core/icons.lua.
        mappings = false,
        breadcrumb = "›",
        separator = "→",
        group = "",
        keys = {
          Up = "Up ",
          Down = "Down ",
          Left = "Left ",
          Right = "Right ",
          C = "Ctrl-",
          M = "Alt-",
          D = "Cmd-",
          S = "Shift-",
          CR = "Enter ",
          Esc = "Esc ",
          ScrollWheelDown = "WheelDown ",
          ScrollWheelUp = "WheelUp ",
          NL = "Enter ",
          BS = "Backspace ",
          Space = "Space ",
          Tab = "Tab ",
          F1 = "F1",
          F2 = "F2",
          F3 = "F3",
          F4 = "F4",
          F5 = "F5",
          F6 = "F6",
          F7 = "F7",
          F8 = "F8",
          F9 = "F9",
          F10 = "F10",
          F11 = "F11",
          F12 = "F12",
        },
      },
      win = {
        border = "single",
        padding = { 1, 2 },
      },
      spec = {
        { "<leader>b", group = "Buffers" },
        { "<leader>e", group = "Explorer" },
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>gf", group = "Git find" },
        { "<leader>gh", group = "PR review" },
        { "<leader>gs", group = "Git changes" },
        { "<leader>r", group = "Replace" },
        { "<leader>s", group = "Search" },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Show buffer-local keymaps",
      },
    },
  },
}
