local M = {}

function M.neo_tree_window()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "neo-tree" then
      return win
    end
  end
end

function M.is_file(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end
  local name = vim.api.nvim_buf_get_name(buf)
  return vim.bo[buf].buflisted
    and vim.bo[buf].buftype == ""
    and name ~= ""
    and vim.fn.isdirectory(name) == 0
end

function M.files()
  local result = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if M.is_file(buf) then
      result[#result + 1] = buf
    end
  end
  table.sort(result)
  return result
end

local function is_empty_unnamed(buf)
  return vim.api.nvim_buf_is_valid(buf)
    and vim.bo[buf].buftype == ""
    and vim.api.nvim_buf_get_name(buf) == ""
    and not vim.bo[buf].modified
    and vim.api.nvim_buf_line_count(buf) == 1
    and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ""
end

function M.remove_empty_unnamed()
  local tree_win = M.neo_tree_window()
  if not tree_win or #M.files() > 0 then
    return
  end

  vim.api.nvim_set_current_win(tree_win)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if win ~= tree_win then
      local buf = vim.api.nvim_win_get_buf(win)
      if is_empty_unnamed(buf) then
        vim.api.nvim_win_close(win, true)
      end
    end
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if is_empty_unnamed(buf) then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end
end

return M
