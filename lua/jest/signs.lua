local M = {}

local ns = vim.api.nvim_create_namespace('jest_signs')

--- M.cache[file][line] = status ('running'|'passed'|'failed'|'pending'|'todo')
M.cache = {}

local STATUS_HL = {
  passed = 'DiagnosticOk',
  failed = 'DiagnosticError',
  pending = 'DiagnosticWarn',
  todo = 'DiagnosticWarn',
  running = 'DiagnosticInfo',
}

-- lower rank wins when aggregating multiple .each cases onto one source line
local STATUS_RANK = { failed = 0, running = 1, pending = 2, todo = 2, passed = 3 }

local function worse(a, b)
  local ra, rb = STATUS_RANK[a] or 4, STATUS_RANK[b] or 4
  return ra <= rb and a or b
end

local function loaded_bufnr(file)
  local bufnr = vim.fn.bufnr(file)
  if bufnr == -1 or not vim.api.nvim_buf_is_loaded(bufnr) then
    return nil
  end
  return bufnr
end

--- Redraw `file`'s gutter signs from the cache. No-op if its buffer isn't loaded.
--- @param file string
function M.render(file)
  local bufnr = loaded_bufnr(file)
  if not bufnr then
    return
  end

  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local by_line = M.cache[file]
  if not by_line then
    return
  end

  local icons = require('jest.config').options.icons
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  for line, status in pairs(by_line) do
    if line >= 1 and line <= line_count then
      pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, line - 1, 0, {
        sign_text = icons[status] or '?',
        sign_hl_group = STATUS_HL[status] or 'Comment',
      })
    end
  end
end

--- Mark tests in `file` as running, before a run's results arrive.
--- @param file string
--- @param lines integer[]|nil specific source lines to mark, preserving the
---   rest of the file's cached statuses (e.g. a single run_nearest target);
---   omit to mark every known test in the file, replacing its whole cache
---   (e.g. a whole-file run).
function M.mark_running(file, lines)
  if not require('jest.config').options.signs.enabled then
    return
  end

  if lines then
    local by_line = M.cache[file] or {}
    for _, line in ipairs(lines) do
      by_line[line] = 'running'
    end
    M.cache[file] = by_line
  else
    local by_line = {}
    for _, t in ipairs(require('jest.finder').file_all_tests(file)) do
      by_line[t.line] = 'running'
    end
    M.cache[file] = by_line
  end

  M.render(file)
end

--- Update `file`'s sign cache from a completed run's result rows for that file.
--- @param file string
--- @param rows table[] flattened jest result rows scoped to this file
function M.update(file, rows)
  if not require('jest.config').options.signs.enabled then
    return
  end

  local by_line = {}
  for _, t in ipairs(require('jest.finder').file_all_tests(file)) do
    if t.kind == 'literal' then
      for _, row in ipairs(rows) do
        if row.fullName == t.fullName then
          by_line[t.line] = row.status
          break
        end
      end
    else -- 'each': aggregate every generated case matching this block's pattern
      -- our patterns are JS-regex-escaped (for jest's --testNamePattern); \v
      -- makes vim's regex engine use matching (non-inverted) escaping rules.
      local re_ok, re = pcall(vim.regex, '\\v' .. t.pattern)
      if re_ok then
        local status = nil
        for _, row in ipairs(rows) do
          if row.fullName and re:match_str(row.fullName) then
            status = status and worse(status, row.status) or row.status
          end
        end
        if status then
          by_line[t.line] = status
        end
      end
    end
  end

  M.cache[file] = by_line
  M.render(file)
end

function M.setup()
  local group = vim.api.nvim_create_augroup('jest_signs', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufEnter' }, {
    group = group,
    callback = function(args)
      local file = vim.api.nvim_buf_get_name(args.buf)
      if file ~= '' and M.cache[file] then
        M.render(file)
      end
    end,
  })
end

return M
