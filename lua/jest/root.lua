local uv = vim.uv or vim.loop

local M = {}

--- Find the nearest package.json directory upward from `path`.
--- @param path string|nil file path to start searching from (defaults to current buffer)
--- @return string root directory
function M.find_root(path)
  path = path or vim.api.nvim_buf_get_name(0)
  if path == '' then
    return vim.fn.getcwd()
  end
  local dir = vim.fs.dirname(path)
  local found = vim.fs.find('package.json', { path = dir, upward = true })[1]
  if not found then
    return vim.fn.getcwd()
  end
  return vim.fs.dirname(found)
end

--- Resolve the jest command to run as an argv table.
--- @param root string project root directory
--- @return string[]
function M.jest_cmd(root)
  local config = require('jest.config').options
  if config.jest_cmd then
    return vim.deepcopy(config.jest_cmd)
  end

  local local_bin = root .. '/node_modules/.bin/jest'
  if uv.fs_stat(local_bin) then
    return { local_bin }
  end
  if uv.fs_stat(root .. '/yarn.lock') then
    return { 'yarn', 'jest' }
  end
  if uv.fs_stat(root .. '/pnpm-lock.yaml') then
    return { 'pnpm', 'exec', 'jest' }
  end
  return { 'npx', 'jest' }
end

return M
