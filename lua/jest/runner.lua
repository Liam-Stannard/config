local M = {}

--- @class JestRunOpts
--- @field path string|nil file or directory positional arg
--- @field test_path_pattern string|nil regex against test file paths (--testPathPattern)
--- @field test_name_pattern string|nil regex against full test names (--testNamePattern)

--- Run jest asynchronously.
--- @param opts JestRunOpts
--- @param on_done fun(decoded: table|nil, err: string|nil)
function M.run(opts, on_done)
  opts = opts or {}

  local bufname = vim.api.nvim_buf_get_name(0)
  local root = require('jest.root').find_root(bufname)
  local cmd = require('jest.root').jest_cmd(root)

  local outfile = vim.fn.tempname() .. '.json'

  -- --colors forces jest to emit ANSI-colored failure messages even though
  -- stdout is a pipe rather than a TTY here, so the Telescope previewer can
  -- render them with real terminal colors instead of plain text.
  local args = { '--json', '--outputFile=' .. outfile, '--testLocationInResults', '--colors' }
  vim.list_extend(args, require('jest.config').options.extra_args or {})

  if opts.test_name_pattern then
    table.insert(args, '--testNamePattern=' .. opts.test_name_pattern)
  end
  if opts.test_path_pattern then
    table.insert(args, '--testPathPattern=' .. opts.test_path_pattern)
  end
  if opts.path then
    table.insert(args, opts.path)
  end

  vim.list_extend(cmd, args)

  -- vim.system's on_exit runs in a fast event context: vim.fn.*/vim.cmd
  -- calls are not allowed there and throw, so everything must go through
  -- vim.schedule before touching them.
  local ok, err_or_handle = pcall(vim.system, cmd, { cwd = root, text = true }, function(res)
    vim.schedule(function()
      -- jest exits non-zero when tests fail; that's not a runner error, only
      -- treat it as one if we truly got no output file to parse.
      local read_ok, contents = pcall(vim.fn.readfile, outfile)
      if not read_ok or #contents == 0 then
        local msg = res.stderr ~= '' and res.stderr or ('jest exited with code ' .. res.code)
        vim.fn.delete(outfile)
        on_done(nil, vim.trim(msg))
        return
      end
      local decoded_ok, decoded = pcall(vim.json.decode, table.concat(contents, '\n'))
      vim.fn.delete(outfile)
      if not decoded_ok then
        on_done(nil, 'failed to decode jest --json output: ' .. tostring(decoded))
        return
      end
      on_done(decoded, nil)
    end)
  end)

  if not ok then
    vim.fn.delete(outfile)
    vim.schedule(function()
      on_done(nil, 'failed to start jest (' .. table.concat(cmd, ' ') .. '): ' .. tostring(err_or_handle))
    end)
  end
end

return M
