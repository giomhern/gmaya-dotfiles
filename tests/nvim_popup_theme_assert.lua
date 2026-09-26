local function check()
  local theme = assert(vim.env.GMAYA_THEME_UNDER_TEST)
  local light = theme == "latte"
    or theme == "tokyonight-day"
    or theme == "rose-pine-dawn"

  assert(
    vim.wait(1500, function()
      return vim.bo.filetype == "neo-tree"
    end),
    theme .. ": Neo-tree did not open"
  )

  require("lazy").load({
    plugins = {
      "noice.nvim",
      "which-key.nvim",
      "blink.cmp",
      "octo.nvim",
      "diffview.nvim",
    },
  })
  vim.api.nvim_exec_autocmds("VimEnter", {})
  assert(
    vim.wait(1000, function()
      return require("noice.config").is_running()
    end),
    theme .. ": Noice did not start"
  )
  assert(
    vim.o.background == (light and "light" or "dark"),
    theme .. ": wrong light/dark mode"
  )

  local function hl(name)
    return vim.api.nvim_get_hl(0, { name = name, link = false })
  end

  local popup_bg =
    assert(hl("NeoTreeNormal").bg, theme .. ": no Neo-tree background")
  local menu = assert(hl("Pmenu").bg, theme .. ": no menu background")
  assert(menu == popup_bg, theme .. ": completion menu differs from Neo-tree")
  for _, name in ipairs({
    "NormalFloat",
    "FloatBorder",
    "FloatTitle",
    "NeoTreeFloatNormal",
    "NeoTreeFloatBorder",
    "NeoTreeFloatTitle",
    "PickerNormal",
    "PickerBorder",
    "WhichKeyNormal",
    "WhichKeyFloat",
    "WhichKeyBorder",
    "WhichKeyTitle",
    "NoicePopup",
    "NoicePopupBorder",
    "NoiceCmdlinePopup",
    "NoiceCmdlinePopupBorder",
    "NoiceCmdlinePopupBorderSearch",
    "NoiceCmdlinePopupTitle",
    "NoiceCmdlinePopupTitleSearch",
    "NoiceCmdlineIcon",
    "NoiceCmdlineIconSearch",
    "NoiceConfirmBorder",
    "BlinkCmpDoc",
    "BlinkCmpDocBorder",
    "BlinkCmpDocSeparator",
    "BlinkCmpSignatureHelp",
    "BlinkCmpSignatureHelpBorder",
    "OctoGreenFloat",
    "OctoRedFloat",
    "OctoBlueFloat",
  }) do
    assert(
      hl(name).bg == popup_bg,
      theme .. ": " .. name .. " differs from Neo-tree"
    )
  end

  -- Completion menus and their borders use the same Neo-tree canvas.
  for _, name in ipairs({
    "PmenuBorder",
    "BlinkCmpMenu",
    "BlinkCmpMenuBorder",
    "NoicePopupmenu",
    "NoicePopupmenuBorder",
  }) do
    assert(hl(name).bg == menu, theme .. ": " .. name .. " differs from menu")
  end

  local function upvalue(fn, wanted)
    for index = 1, 30 do
      local name, value = debug.getupvalue(fn, index)
      if not name then
        break
      end
      if name == wanted then
        return value
      end
    end
  end

  local build =
    assert(upvalue(require("core.picker").find_files, "build_command"))
  local fzf_colors = assert(upvalue(build, "FZF_COLORS"))
  local hex = string.format("#%06x", popup_bg)
  assert(
    fzf_colors:find("--color=" .. vim.o.background, 1, true),
    theme .. ": fzf has the wrong light/dark mode"
  )
  for _, section in ipairs({
    "bg",
    "input-bg",
    "list-bg",
    "preview-bg",
    "header-bg",
    "footer-bg",
  }) do
    assert(
      fzf_colors:find(section .. ":" .. hex, 1, true),
      theme .. ": fzf " .. section .. " differs from Neo-tree"
    )
  end
  vim.fn.system({ "fzf", fzf_colors, "--filter=popup-probe" }, "popup-probe\n")
  assert(vim.v.shell_error == 0, theme .. ": fzf rejected its color options")
end

local ok, err = pcall(check)
if not ok then
  io.stderr:write(tostring(err), "\n")
  vim.cmd.cquit()
end
