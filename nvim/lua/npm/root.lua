local uv = vim.uv or vim.loop

local M = {}

--- Find the project root for `path`: a user-supplied root_dir() function
--- takes precedence when it returns a value, otherwise walk upward looking
--- for root_pattern (default "package.json").
--- @param path string|nil file path to start searching from (defaults to current buffer)
--- @return string root directory
function M.find_root(path)
  path = path or vim.api.nvim_buf_get_name(0)
  if path == '' then
    return vim.fn.getcwd()
  end

  local config = require('npm.config').options
  if config.root_dir then
    local ok, dir = pcall(config.root_dir, path)
    if ok and dir then
      return dir
    end
  end

  local dir = vim.fs.dirname(path)
  local found = vim.fs.find(config.root_pattern or 'package.json', { path = dir, upward = true })[1]
  if not found then
    return vim.fn.getcwd()
  end
  return vim.fs.dirname(found)
end

--- Resolve the "run a script" command for `root`'s package manager as an
--- argv table.
--- @param root string project root directory
--- @param script string npm-scripts key to run
--- @return string[]
function M.run_cmd(root, script)
  local config = require('npm.config').options
  if config.npm_cmd then
    local cmd = vim.deepcopy(config.npm_cmd)
    vim.list_extend(cmd, { 'run', script })
    return cmd
  end

  if uv.fs_stat(root .. '/yarn.lock') then
    return { 'yarn', 'run', script }
  end
  if uv.fs_stat(root .. '/pnpm-lock.yaml') then
    return { 'pnpm', 'run', script }
  end
  return { 'npm', 'run', script }
end

return M
