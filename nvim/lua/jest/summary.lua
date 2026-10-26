local format = require('jest.format')

local M = {
  bufnr = nil,
  winid = nil,
  prev_winid = nil, -- window to jump into on <CR>, i.e. the one active before opening
  last_rows = nil, -- most recently rendered rows, kept even while closed
  last_opts = nil, -- { title, summary }
  line_rows = nil, -- 1-indexed buffer line -> row, for <CR> jump lookups
}

local ns = vim.api.nvim_create_namespace('jest_summary')

local SPLIT_DIR = { left = 'left', right = 'right', top = 'above', bottom = 'below' }

local function jump_to_selected()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local row = M.line_rows and M.line_rows[line]
  if not row or row.is_header or not row.file then
    return
  end

  local target_win = (M.prev_winid and vim.api.nvim_win_is_valid(M.prev_winid)) and M.prev_winid or nil
  if target_win then
    vim.api.nvim_set_current_win(target_win)
  else
    vim.cmd('wincmd p')
  end

  vim.cmd('edit ' .. vim.fn.fnameescape(row.file))
  if row.line then
    pcall(vim.api.nvim_win_set_cursor, 0, { row.line, (row.column or 1) - 1 })
  end
end

local function ensure_buf()
  if M.bufnr and vim.api.nvim_buf_is_valid(M.bufnr) then
    return M.bufnr
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'hide'
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = 'jest-summary'
  vim.bo[buf].modifiable = false

  vim.keymap.set('n', '<CR>', jump_to_selected, { buffer = buf, nowait = true, desc = 'Jest: jump to test' })
  vim.keymap.set('n', 'q', function() M.close() end, { buffer = buf, nowait = true, desc = 'Jest: close summary' })
  vim.keymap.set(
    'n',
    '<C-r>',
    function() require('jest').run_last() end,
    { buffer = buf, nowait = true, desc = 'Jest: rerun last' }
  )

  M.bufnr = buf
  return buf
end

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

local function draw()
  if not M.is_open() then
    return
  end

  local lines = {}
  local highlights = {} -- { line, col_start, col_end, hl }
  M.line_rows = {}

  if not M.last_rows then
    lines = { 'No results yet. Run a test to populate this panel.' }
  else
    local opts = M.last_opts or {}
    local summary = opts.summary or {}
    table.insert(
      lines,
      string.format(
        '%s  [%d passed / %d failed / %d total]',
        opts.title or 'Jest Results',
        summary.passed or 0,
        summary.failed or 0,
        summary.total or 0
      )
    )
    table.insert(lines, '')

    local icons = require('jest.config').options.icons
    local display_rows = format.group(M.last_rows)

    for _, row in ipairs(display_rows) do
      local icon, text = format.label(row, icons)
      local line_idx = #lines + 1
      if not icon then
        table.insert(lines, text)
        table.insert(highlights, { line = line_idx, col_start = 0, col_end = #text, hl = 'Comment' })
      else
        table.insert(lines, string.format('%s %s', icon, text))
        local hl = format.STATUS_HL[row.status]
        if hl then
          table.insert(highlights, { line = line_idx, col_start = 0, col_end = #icon, hl = hl })
        end
      end
      M.line_rows[line_idx] = row
    end
  end

  vim.bo[M.bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(M.bufnr, 0, -1, false, lines)
  vim.bo[M.bufnr].modifiable = false

  vim.api.nvim_buf_clear_namespace(M.bufnr, ns, 0, -1)
  for _, h in ipairs(highlights) do
    pcall(vim.api.nvim_buf_add_highlight, M.bufnr, ns, h.hl, h.line - 1, h.col_start, h.col_end)
  end
end

--- Update the panel's data, redrawing immediately if it's open. Safe to
--- call whether or not the window is currently visible; the data is cached
--- either way so the next M.open() shows fresh results.
--- @param rows table[] flattened jest result rows (see jest.parser.flatten)
--- @param opts table|nil { title, summary = { passed, failed, total } }
function M.render(rows, opts)
  M.last_rows = rows
  M.last_opts = opts
  draw()
end

function M.open()
  if M.is_open() then
    vim.api.nvim_set_current_win(M.winid)
    return
  end

  M.prev_winid = vim.api.nvim_get_current_win()

  local cfg = require('jest.config').options.summary
  local split = SPLIT_DIR[cfg.position] or 'right'
  local buf = ensure_buf()

  local win_opts = { split = split, win = -1 }
  if split == 'left' or split == 'right' then
    win_opts.width = cfg.width
  else
    win_opts.height = cfg.height
  end

  M.winid = vim.api.nvim_open_win(buf, true, win_opts)
  vim.wo[M.winid].number = false
  vim.wo[M.winid].relativenumber = false
  vim.wo[M.winid].signcolumn = 'no'
  vim.wo[M.winid].wrap = false
  vim.wo[M.winid].cursorline = true

  draw()
end

function M.toggle()
  if M.is_open() then
    M.close()
  else
    M.open()
  end
end

return M
