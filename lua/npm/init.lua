local M = {}

local last_script = nil -- { root, name }

local function notify(msg, level)
  vim.notify(msg, level, { title = 'Npm' })
end

function M.setup(opts)
  require('npm.config').setup(opts)
end

--- Run `script` (an npm-scripts key) from `root`'s package.json.
--- @param root string project root directory
--- @param script string
function M.run_in(root, script)
  local list, err = require('npm.scripts').list(root)
  if err then
    notify(err, vim.log.levels.WARN)
    return
  end

  local exists = false
  for _, s in ipairs(list) do
    if s.name == script then
      exists = true
      break
    end
  end
  if not exists then
    notify('no such script: ' .. script, vim.log.levels.WARN)
    return
  end

  last_script = { root = root, name = script }

  local cfg = require('npm.config').options
  if cfg.notify.on_start then
    notify('Running: npm run ' .. script)
  end

  local cmd = require('npm.root').run_cmd(root, script)
  local bufnr = require('npm.runner').run(script, cmd, root, function(code)
    if code ~= 0 and cfg.notify.on_error then
      notify(('%s exited with code %d'):format(script, code), vim.log.levels.WARN)
    end
  end)

  if bufnr and (cfg.output.auto_open == 'on_start' or cfg.output.auto_open == 'always') then
    require('npm.output').show(script, bufnr)
  end
end

--- Run `script` for the project containing the current buffer (or cwd, if
--- the current buffer has no file).
--- @param script string
function M.run(script)
  local file = vim.api.nvim_buf_get_name(0)
  local root = require('npm.root').find_root(file ~= '' and file or nil)
  M.run_in(root, script)
end

--- Open a Telescope picker of the project's npm-scripts to run one.
function M.pick()
  require('npm.picker').pick()
end

--- Rerun the most recently run script.
function M.run_last()
  if not last_script then
    notify('no previous run', vim.log.levels.WARN)
    return
  end
  M.run_in(last_script.root, last_script.name)
end

--- Stop `script` (defaults to the most recently run one).
--- @param script string|nil
function M.stop(script)
  script = script or (last_script and last_script.name)
  if not script then
    notify('no script to stop', vim.log.levels.WARN)
    return
  end
  if not require('npm.runner').stop(script) then
    notify(script .. ' is not running', vim.log.levels.WARN)
  end
end

--- Stop every currently-running script.
function M.stop_all()
  require('npm.runner').stop_all()
end

--- Toggle the dockable output panel for the most recently run script.
function M.toggle_output()
  if not last_script then
    notify('no output to show', vim.log.levels.WARN)
    return
  end
  local bufnr = require('npm.runner').bufnr(last_script.name)
  if not bufnr then
    notify('no output to show', vim.log.levels.WARN)
    return
  end
  require('npm.output').toggle(last_script.name, bufnr)
end

return M
