local format = require('jest.format')

local M = {}

local ns = vim.api.nvim_create_namespace('jest_signs')
local diag_ns = vim.api.nvim_create_namespace('jest_diagnostics')

--- M.cache[file][line] = status ('running'|'passed'|'failed'|'pending'|'todo')
M.cache = {}
--- M.messages[file][line] = ANSI-stripped failure message, for failed lines
M.messages = {}

local function loaded_bufnr(file)
  local bufnr = vim.fn.bufnr(file)
  if bufnr == -1 or not vim.api.nvim_buf_is_loaded(bufnr) then
    return nil
  end
  return bufnr
end

--- Redraw `file`'s gutter signs (and diagnostics, if enabled) from the
--- cache. No-op if its buffer isn't loaded.
--- @param file string
function M.render(file)
  local bufnr = loaded_bufnr(file)
  if not bufnr then
    return
  end

  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local by_line = M.cache[file]
  local icons = require('jest.config').options.icons
  local diagnostics_enabled = require('jest.config').options.diagnostics.enabled
  local diagnostics = {}

  if by_line then
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    local messages = M.messages[file] or {}
    for line, status in pairs(by_line) do
      if line >= 1 and line <= line_count then
        pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, line - 1, 0, {
          sign_text = icons[status] or '?',
          sign_hl_group = format.STATUS_HL[status] or 'Comment',
        })
        if diagnostics_enabled and status == 'failed' and messages[line] then
          table.insert(diagnostics, {
            lnum = line - 1,
            col = 0,
            severity = vim.diagnostic.severity.ERROR,
            message = messages[line],
            source = 'jest',
          })
        end
      end
    end
  end

  -- always set (possibly empty): clears stale diagnostics if disabled mid-session
  vim.diagnostic.set(diag_ns, bufnr, diagnostics)
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
  local messages_by_line = {}

  local function record(line, status, message)
    by_line[line] = status
    if status == 'failed' and message then
      messages_by_line[line] = format.strip_ansi(message)
    end
  end

  for _, t in ipairs(require('jest.finder').file_all_tests(file)) do
    if t.kind == 'literal' then
      for _, row in ipairs(rows) do
        if row.fullName == t.fullName then
          record(t.line, row.status, row.failureMessages and row.failureMessages[1])
          break
        end
      end
    else -- 'each': aggregate every generated case matching this block's pattern
      -- our patterns are JS-regex-escaped (for jest's --testNamePattern); \v
      -- makes vim's regex engine use matching (non-inverted) escaping rules.
      local re_ok, re = pcall(vim.regex, '\\v' .. t.pattern)
      if re_ok then
        local status, message = nil, nil
        for _, row in ipairs(rows) do
          if row.fullName and re:match_str(row.fullName) then
            if not status or format.status_rank(row.status) < format.status_rank(status) then
              status = row.status
              message = row.failureMessages and row.failureMessages[1]
            end
          end
        end
        if status then
          record(t.line, status, message)
        end
      end
    end
  end

  M.cache[file] = by_line
  M.messages[file] = messages_by_line
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
