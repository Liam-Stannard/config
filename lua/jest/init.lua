local M = {}

local last_run = nil -- { opts: JestRunOpts, title: string }
local last_rows = nil -- flattened rows from the most recent run, for M.trouble()

local function notify(msg, level)
  vim.notify(msg, level, { title = 'Jest' })
end

-- jest's --testLocationInResults reports lines against transformed source
-- (e.g. under ts-jest), not the original file, so prefer our own
-- treesitter-derived locations for literal (non-.each) tests when available.
local function fix_locations(rows)
  local lines_by_file = {}
  for _, row in ipairs(rows) do
    if row.file and row.fullName then
      local lines = lines_by_file[row.file]
      if lines == nil then
        lines = require('jest.finder').file_test_lines(row.file)
        lines_by_file[row.file] = lines
      end
      local line = lines[row.fullName]
      if line then
        row.line = line
        row.column = nil
      end
    end
  end
end

local function open_results(decoded, err, title)
  if err then
    notify(err, vim.log.levels.ERROR)
    return
  end
  local rows = require('jest.parser').flatten(decoded)
  fix_locations(rows)
  last_rows = rows
  require('jest.picker').show(rows, {
    title = title,
    summary = {
      passed = decoded.numPassedTests,
      failed = decoded.numFailedTests,
      total = decoded.numTotalTests,
    },
  })
end

local function run(opts, title)
  last_run = { opts = opts, title = title }
  notify('Running: ' .. title)
  require('jest.runner').run(opts, function(decoded, err)
    open_results(decoded, err, title)
  end)
end

function M.setup(opts)
  require('jest.config').setup(opts)
end

function M.run_file_for(file)
  run({ path = file }, 'Jest: ' .. vim.fn.fnamemodify(file, ':t'))
end

function M.run_file()
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then
    notify('current buffer has no file', vim.log.levels.WARN)
    return
  end
  M.run_file_for(file)
end

function M.run_dir_for(dir)
  run(
    { test_path_pattern = require('jest.finder').escape_regex(dir) },
    'Jest: ' .. vim.fn.fnamemodify(dir, ':t') .. '/'
  )
end

function M.run_dir()
  local file = vim.api.nvim_buf_get_name(0)
  local dir = file ~= '' and vim.fn.fnamemodify(file, ':h') or vim.fn.getcwd()
  M.run_dir_for(dir)
end

function M.pick()
  require('jest.picker').pick()
end

function M.run_nearest()
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then
    notify('current buffer has no file', vim.log.levels.WARN)
    return
  end
  local spec, err = require('jest.finder').nearest(0)
  if not spec then
    notify(err or 'no test found under cursor', vim.log.levels.WARN)
    return
  end
  run({ path = file, test_name_pattern = spec.pattern }, 'Jest: nearest')
end

function M.run_last()
  if not last_run then
    notify('no previous run', vim.log.levels.WARN)
    return
  end
  run(last_run.opts, last_run.title)
end

--- POC: view the last run's results in trouble.nvim instead of Telescope.
function M.trouble()
  if not last_rows then
    notify('no results to show', vim.log.levels.WARN)
    return
  end
  require('jest.picker').open_trouble(last_rows)
end

return M
