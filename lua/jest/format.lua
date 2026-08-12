local M = {}

-- highlight groups are core Neovim diagnostic groups, so they follow
-- whatever colorscheme is active rather than hardcoding colors.
M.STATUS_HL = {
  passed = 'DiagnosticOk',
  failed = 'DiagnosticError',
  pending = 'DiagnosticWarn',
  todo = 'DiagnosticWarn',
  running = 'DiagnosticInfo',
}

-- lower rank = more urgent/worth-seeing-first; used both for sort order
-- (picker/summary) and for worst-status-wins aggregation (signs).
local STATUS_RANK = { failed = 0, running = 1, pending = 2, todo = 2, passed = 3 }

--- @param status string|nil
--- @return integer
function M.status_rank(status)
  return STATUS_RANK[status] or 4
end

--- @param a string status
--- @param b string status
--- @return string the more urgent of the two statuses
function M.worse(a, b)
  return M.status_rank(a) <= M.status_rank(b) and a or b
end

--- Strip ANSI escape codes, e.g. for a failure message shown in a plain-text
--- UI (vim.diagnostic) rather than a real terminal buffer.
--- @param text string
--- @return string
function M.strip_ansi(text)
  return (text:gsub('\27%[[0-9;]*m', ''))
end

-- jest test titles can embed arbitrary interpolated values (e.g. `it.each`
-- with a `$value` of `'a\n'`), including raw control characters. A literal
-- newline breaks line-based UIs that assume one buffer line per entry
-- (Telescope's results buffer, the summary window), so collapse them
-- before ever displaying a row's text.
--- @param text string
--- @return string
function M.sanitize(text)
  return (text:gsub('[\r\n\t]', ' '))
end

-- the outermost describe() is usually the file/class-under-test's name
-- (e.g. "AuthService"), which is redundant once results are grouped by
-- file, so drop it from the displayed/searchable name and show the
-- remaining nested describes + title instead.
--- @param row table
--- @return string
function M.short_name(row)
  local ancestors = row.ancestorTitles
  if not ancestors or #ancestors <= 1 then
    return row.fullName or row.title or row.file or ''
  end
  local segments = {}
  for i = 2, #ancestors do
    table.insert(segments, ancestors[i])
  end
  table.insert(segments, row.title or '')
  return table.concat(segments, ' ')
end

--- Sort `rows` in place (grouped by file, most-urgent-first within each
--- file), then return a list with a non-interactive header row spliced in
--- before each file group when the run spans more than one file.
--- @param rows table[] flattened jest result rows (see jest.parser.flatten)
--- @return table[] display_rows rows and, for multi-file runs, header rows
---   ({ is_header = true, file, file_label }) interleaved between groups
function M.group(rows)
  table.sort(rows, function(a, b)
    if a.file ~= b.file then
      return (a.file or '') < (b.file or '')
    end
    return M.status_rank(a.status) < M.status_rank(b.status)
  end)

  local files = {}
  for _, row in ipairs(rows) do
    if row.file then
      files[row.file] = true
    end
  end
  if vim.tbl_count(files) <= 1 then
    return rows
  end

  local display_rows = {}
  local last_file = nil
  for _, row in ipairs(rows) do
    if row.file ~= last_file then
      table.insert(display_rows, {
        is_header = true,
        file = row.file,
        file_label = row.file and vim.fn.fnamemodify(row.file, ':~:.') or '?',
      })
      last_file = row.file
    end
    table.insert(display_rows, row)
  end
  return display_rows
end

--- @param row table a row from M.group()'s output (result row or header)
--- @param icons table<string, string>
--- @return string|nil icon nil for header rows
--- @return string text
function M.label(row, icons)
  if row.is_header then
    return nil, '── ' .. row.file_label .. ' ──'
  end
  return icons[row.status] or '?', M.sanitize(M.short_name(row))
end

return M
