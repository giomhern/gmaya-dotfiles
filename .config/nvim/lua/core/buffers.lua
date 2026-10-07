local M = {}

function M.neo_tree_window(tab)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab or 0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "neo-tree" then
      return win
    end
  end
end

-- Neo-tree replaces a deleted file shown in a window with a listed, empty
-- buffer. Reclaim only windows that showed the deleted path; other unnamed
-- buffers may be intentional drafts in another split or tab.
function M.recover_deleted_file_windows(windows)
  local previous_tab = vim.api.nvim_get_current_tabpage()
  local previous_win = vim.api.nvim_get_current_win()
  for _, win in ipairs(windows) do
    if vim.api.nvim_win_is_valid(win) then
      local blank = vim.api.nvim_win_get_buf(win)
      if M.is_empty_unnamed(blank) then
        local files = M.files()
        if #files > 0 then
          vim.api.nvim_win_set_buf(win, files[1])
        else
          local tab = vim.api.nvim_win_get_tabpage(win)
          vim.api.nvim_set_current_tabpage(tab)
          local tree_win = M.neo_tree_window(tab)
          if tree_win and tree_win ~= win then
            if vim.api.nvim_get_current_win() == win then
              vim.api.nvim_set_current_win(tree_win)
            end
            vim.api.nvim_win_close(win, false)
          else
            vim.api.nvim_set_current_win(win)
            require("neo-tree.command").execute({
              action = "focus",
              source = "filesystem",
              position = "current",
              dir = vim.fn.getcwd(),
            })
          end
        end
        if
          vim.api.nvim_buf_is_valid(blank) and #vim.fn.win_findbuf(blank) == 0
        then
          vim.api.nvim_buf_delete(blank, { force = true })
        end
      end
    end
  end
  if vim.api.nvim_tabpage_is_valid(previous_tab) then
    vim.api.nvim_set_current_tabpage(previous_tab)
    if vim.api.nvim_win_is_valid(previous_win) then
      vim.api.nvim_set_current_win(previous_win)
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

function M.is_empty_unnamed(buf)
  return vim.api.nvim_buf_is_valid(buf)
    and vim.bo[buf].buflisted
    and vim.bo[buf].buftype == ""
    and vim.bo[buf].modifiable
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
      if M.is_empty_unnamed(buf) then
        vim.api.nvim_win_close(win, true)
      end
    end
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    -- A different tab can still be using an empty scratch buffer. Only reap
    -- placeholders that no window displays after the current tree opens.
    if M.is_empty_unnamed(buf) and #vim.fn.win_findbuf(buf) == 0 then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end
end

return M
