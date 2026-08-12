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

local function make_display(entry)
  local row = entry.value
  local icon_map = icons()
  local icon = icon_map[row.status] or '?'
  local text = sanitize(row.fullName or row.title or row.file or '')
  local display_str = string.format('%s %s', icon, text)

  local hl = STATUS_HL[row.status]
  if hl then
    return display_str, { { { 0, #icon }, hl } }
  end
  return display_str
end

local function entry_maker(row)
  return {
    value = row,
    display = make_display,
    ordinal = sanitize(row.fullName or row.title or row.file or ''),
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

  table.sort(rows, function(a, b)
    return status_rank(a.status) < status_rank(b.status)
  end)

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
        results = rows,
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

        return true
      end,
    })
    :find()
end

return M
