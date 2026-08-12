local M = {}

local last_run = nil -- { opts: JestRunOpts, title: string }
local last_rows = nil -- flattened rows from the most recent run, for M.trouble()/M.reopen()
local last_summary = nil -- { passed, failed, total } from the most recent run

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

local function update_signs(rows)
  local rows_by_file = {}
  for _, row in ipairs(rows) do
    if row.file then
      local list = rows_by_file[row.file]
      if not list then
        list = {}
        rows_by_file[row.file] = list
      end
      table.insert(list, row)
    end
  end
  for file, file_rows in pairs(rows_by_file) do
    require('jest.signs').update(file, file_rows)
  end
end

local function open_results(decoded, err, title)
  if err then
    if require('jest.config').options.notify.on_error then
      notify(err, vim.log.levels.ERROR)
    end
    return
  end
  local rows = require('jest.parser').flatten(decoded)
  fix_locations(rows)
  update_signs(rows)
  last_rows = rows
  last_summary = {
    passed = decoded.numPassedTests,
    failed = decoded.numFailedTests,
    total = decoded.numTotalTests,
  }

  local cfg = require('jest.config').options
  local display_opts = { title = title, summary = last_summary }

  local summary_auto = cfg.summary.auto_open
  require('jest.summary').render(rows, display_opts)
  if summary_auto == 'on_complete' or summary_auto == 'always' then
    if not require('jest.summary').is_open() then
      require('jest.summary').open()
    end
  end

  local open_picker = cfg.picker.auto_open == 'always'
    or (cfg.picker.auto_open == 'on_failure' and (last_summary.failed or 0) > 0)
  if open_picker then
    require('jest.picker').show(rows, display_opts)
  end
end

local function run(opts, title)
  last_run = { opts = opts, title = title }

  local cfg = require('jest.config').options
  if cfg.notify.on_start then
    notify('Running: ' .. title)
  end

  local summary_auto = cfg.summary.auto_open
  if summary_auto == 'on_start' or summary_auto == 'always' then
    if not require('jest.summary').is_open() then
      require('jest.summary').open()
    end
  end

  require('jest.runner').run(opts, function(decoded, err)
    open_results(decoded, err, title)
  end)
end

function M.setup(opts)
  require('jest.config').setup(opts)
  require('jest.signs').setup()
end

function M.run_file_for(file)
  require('jest.signs').mark_running(file)
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

-- mark every test file under `dir` as running, without blocking on the
-- listing before kicking off the actual jest run
local function mark_dir_running(dir)
  local cmd = { 'rg', '--files' }
  for _, g in ipairs(require('jest.config').options.test_glob) do
    vim.list_extend(cmd, { '--glob', g })
  end
  vim.list_extend(cmd, { '--glob', '!**/node_modules/**', dir })

  -- best-effort: if rg can't even be spawned, the run just proceeds without
  -- a "running" indicator rather than failing the whole directory run
  pcall(vim.system, cmd, { text = true }, function(res)
    vim.schedule(function()
      if res.code == 0 and res.stdout then
        for _, f in ipairs(vim.split(res.stdout, '\n', { trimempty = true })) do
          require('jest.signs').mark_running(vim.fn.fnamemodify(f, ':p'))
        end
      end
    end)
  end)
end

function M.run_dir_for(dir)
  mark_dir_running(dir)
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
  require('jest.signs').mark_running(file, { spec.line })
  run({ path = file, test_name_pattern = spec.pattern }, 'Jest: nearest')
end

function M.run_last()
  if not last_run then
    notify('no previous run', vim.log.levels.WARN)
    return
  end
  if last_rows then
    local files = {}
    for _, row in ipairs(last_rows) do
      if row.file then
        files[row.file] = true
      end
    end
    for file in pairs(files) do
      require('jest.signs').mark_running(file)
    end
  end
  run(last_run.opts, last_run.title)
end

--- Toggle a persistent, dockable panel showing the last run's results.
function M.toggle_summary()
  require('jest.summary').toggle()
end

--- Reopen the last run's results in the Telescope picker without rerunning.
function M.reopen()
  if not last_rows then
    notify('no results to show', vim.log.levels.WARN)
    return
  end
  require('jest.picker').show(last_rows, {
    title = last_run and last_run.title or 'Jest Results',
    summary = last_summary,
  })
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
