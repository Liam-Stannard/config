local M = {
  winid = nil,
  current = nil, -- script name currently displayed
}

local SPLIT_DIR = { left = 'left', right = 'right', top = 'above', bottom = 'below' }

--- @return boolean
function M.is_open()
  return M.winid ~= nil and vim.api.nvim_win_is_valid(M.winid)
end

function M.close()
  if M.is_open() then
    vim.api.nvim_win_close(M.winid, true)
  end
  M.winid = nil
end

--- Show `script`'s output buffer in the dockable window, opening it (without
--- stealing focus) if it isn't already open.
--- @param script string
--- @param bufnr integer
function M.show(script, bufnr)
  M.current = script

  if M.is_open() then
    vim.api.nvim_win_set_buf(M.winid, bufnr)
    return
  end

  local cfg = require('npm.config').options.output
  local split = SPLIT_DIR[cfg.position] or 'right'
  local win_opts = { split = split, win = -1 }
  if split == 'left' or split == 'right' then
    win_opts.width = cfg.width
  else
    win_opts.height = cfg.height
  end

  local prev_win = vim.api.nvim_get_current_win()
  M.winid = vim.api.nvim_open_win(bufnr, false, win_opts)
  vim.wo[M.winid].number = false
  vim.wo[M.winid].relativenumber = false
  vim.wo[M.winid].signcolumn = 'no'
  vim.api.nvim_set_current_win(prev_win)
end

--- @param script string
--- @param bufnr integer
function M.toggle(script, bufnr)
  if M.is_open() and M.current == script then
    M.close()
  else
    M.show(script, bufnr)
  end
end

return M
