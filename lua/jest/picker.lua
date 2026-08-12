local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local previewers = require('telescope.previewers')

local M = {}

local function icons()
  return require('jest.config').options.icons
end

-- highlight groups are core Neovim diagnostic groups, so they follow
-- whatever colorscheme is active rather than hardcoding colors.
local STATUS_HL = {
  passed = 'DiagnosticOk',
  failed = 'DiagnosticError',
  pending = 'DiagnosticWarn',
  todo = 'DiagnosticWarn',
}

-- jest test titles can embed arbitrary interpolated values (e.g. `it.each`
-- with a `$value` of `'a\n'`), including raw control characters. A literal
-- newline in a result's display text breaks Telescope's results buffer,
-- which assumes exactly one buffer line per entry, so collapse them before
-- ever handing text to Telescope.
local function sanitize(text)
  return (text:gsub('[\r\n\t]', ' '))
end

-- the outermost describe() is usually the file/class-under-test's name
-- (e.g. "AuthService"), which is redundant once results are grouped by
-- file, so drop it from the displayed/searchable name and show the
-- remaining nested describes + title instead.
local function short_name(row)
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

local function make_display(entry)
  local row = entry.value
  if row.is_header then
    local text = '── ' .. row.file_label .. ' ──'
    return text, { { { 0, #text }, 'Comment' } }
  end

  local icon_map = icons()
  local icon = icon_map[row.status] or '?'
  local text = sanitize(short_name(row))
  local display_str = string.format('%s %s', icon, text)

  local hl = STATUS_HL[row.status]
  if hl then
    return display_str, { { { 0, #icon }, hl } }
  end
  return display_str
end

local function entry_maker(row)
  if row.is_header then
    return {
      value = row,
      display = make_display,
      ordinal = row.file_label or '',
    }
  end
  return {
    value = row,
    display = make_display,
    ordinal = sanitize(short_name(row)),
    filename = row.file,
    lnum = row.line,
    col = row.column,
  }
end

local STATUS_RANK = { failed = 0, pending = 1, todo = 1, passed = 2 }

local function status_rank(status)
  return STATUS_RANK[status] or 3
end

-- jest emits ANSI-colored failure/diff output (see runner.lua's --colors
-- flag); write it to a scratch file and `cat` it through a real terminal
-- job so Neovim's terminal emulator renders the colors, rather than
-- stripping the escape codes down to plain text.
local function get_command(entry)
  local row = entry.value
  if row.is_header then
    local path = vim.fn.tempname()
    vim.fn.writefile({ row.file_label or row.file or '' }, path)
    return { 'cat', path }
  end

  local icon_map = icons()
  local lines = {}

  table.insert(lines, string.format('%s %s', icon_map[row.status] or '?', row.fullName or row.title or ''))
  table.insert(lines, row.file or '')
  table.insert(lines, '')

  if row.failureMessages and #row.failureMessages > 0 then
    for _, msg in ipairs(row.failureMessages) do
      vim.list_extend(lines, vim.split(msg, '\n', { plain = true }))
      table.insert(lines, '')
    end
  elseif row.status == 'passed' then
    table.insert(lines, 'Passed.')
  end

  local path = vim.fn.tempname()
  vim.fn.writefile(lines, path)
  return { 'cat', path }
end

--- @param rows table[] flattened jest result rows (see jest.parser.flatten)
--- @param opts table|nil { title, summary = { passed, failed, total } }
function M.show(rows, opts)
  opts = opts or {}

  local files = {}
  for _, row in ipairs(rows) do
    if row.file then
      files[row.file] = true
    end
  end
  local multi_file = vim.tbl_count(files) > 1

  -- group by file, failed-first within each file
  table.sort(rows, function(a, b)
    if a.file ~= b.file then
      return (a.file or '') < (b.file or '')
    end
    return status_rank(a.status) < status_rank(b.status)
  end)

  -- for multi-file runs, splice in a non-interactive header row before each
  -- new file group instead of repeating the file path on every result row
  local display_rows = rows
  if multi_file then
    display_rows = {}
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
  end

  local summary = opts.summary or {}
  local prompt_title = string.format(
    '%s  [%d passed / %d failed / %d total]',
    opts.title or 'Jest Results',
    summary.passed or 0,
    summary.failed or 0,
    summary.total or 0
  )

  pickers
    .new({}, {
      prompt_title = prompt_title,
      finder = finders.new_table({
        results = display_rows,
        entry_maker = entry_maker,
      }),
      sorter = conf.generic_sorter({}),
      previewer = previewers.new_termopen_previewer({
        title = 'Details',
        get_command = get_command,
      }),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if entry and entry.filename and entry.filename ~= '' then
            vim.cmd('edit ' .. vim.fn.fnameescape(entry.filename))
            if entry.lnum then
              pcall(vim.api.nvim_win_set_cursor, 0, { entry.lnum, (entry.col or 1) - 1 })
            end
          end
        end)

        local function rerun()
          actions.close(prompt_bufnr)
          require('jest').run_last()
        end
        map('i', '<C-r>', rerun)
        map('n', '<C-r>', rerun)

        local function open_trouble()
          actions.close(prompt_bufnr)
          M.open_trouble(rows)
        end
        map('i', '<C-t>', open_trouble)
        map('n', '<C-t>', open_trouble)

        return true
      end,
    })
    :find()
end

local QF_TYPE = { failed = 'E', pending = 'W', todo = 'W', passed = 'I' }

--- POC: open results in trouble.nvim's quickfix view instead of Telescope's
--- flat list, for real collapsible-by-file grouping (`zo`/`zc`).
--- @param rows table[] flattened jest result rows (see jest.parser.flatten)
function M.open_trouble(rows)
  -- trouble.nvim lazy-loads on the :Trouble command, so a bare require()
  -- here would miss its setup()/config; ask lazy.nvim to load it first.
  local lazy_ok, lazy = pcall(require, 'lazy')
  if lazy_ok then
    pcall(lazy.load, { plugins = { 'trouble.nvim' } })
  end

  local ok = pcall(require, 'trouble')
  if not ok then
    vim.notify('Jest: trouble.nvim not available', vim.log.levels.WARN, { title = 'Jest' })
    return
  end

  local items = {}
  for _, row in ipairs(rows) do
    if not row.is_header then
      table.insert(items, {
        filename = row.file,
        lnum = row.line or 1,
        text = short_name(row),
        type = QF_TYPE[row.status] or 'I',
      })
    end
  end

  vim.fn.setqflist({}, ' ', { title = 'Jest Results', items = items })
  require('trouble').open('qflist')
end

--- Pick a test file to run (<CR>), or run its containing directory (<C-d>),
--- rather than always acting on the current buffer.
function M.pick()
  local test_glob = require('jest.config').options.test_glob
  local find_command = { 'rg', '--files' }
  for _, g in ipairs(test_glob) do
    vim.list_extend(find_command, { '--glob', g })
  end
  vim.list_extend(find_command, { '--glob', '!**/node_modules/**' })

  require('telescope.builtin').find_files({
    prompt_title = 'Jest: pick file (<CR> run file, <C-d> run directory)',
    find_command = find_command,
    attach_mappings = function(prompt_bufnr, map)
      local function run_selected(as_dir)
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if not entry then
          return
        end
        local path = entry.path
        if as_dir then
          require('jest').run_dir_for(vim.fn.fnamemodify(path, ':h'))
        else
          require('jest').run_file_for(path)
        end
      end

      actions.select_default:replace(function() run_selected(false) end)
      map('i', '<C-d>', function() run_selected(true) end)
      map('n', '<C-d>', function() run_selected(true) end)

      return true
    end,
  })
end

return M
