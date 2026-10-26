local M = {}

--- Read and parse the `scripts` table out of `root`'s package.json.
--- @param root string project root directory
--- @return table[] { name, command }[], sorted by name (empty on error)
--- @return string|nil err
function M.list(root)
  local path = root .. '/package.json'
  if vim.fn.filereadable(path) == 0 then
    return {}, 'no package.json found at ' .. path
  end

  local read_ok, contents = pcall(vim.fn.readfile, path)
  if not read_ok then
    return {}, 'failed to read ' .. path
  end

  local decode_ok, decoded = pcall(vim.json.decode, table.concat(contents, '\n'))
  if not decode_ok or type(decoded) ~= 'table' or type(decoded.scripts) ~= 'table' then
    return {}, 'no scripts found in ' .. path
  end

  local names = {}
  for name in pairs(decoded.scripts) do
    table.insert(names, name)
  end
  table.sort(names)

  local list = {}
  for _, name in ipairs(names) do
    table.insert(list, { name = name, command = decoded.scripts[name] })
  end
  return list, nil
end

return M
