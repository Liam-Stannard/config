local M = {}

--- @class JestRunOpts
--- @field path string|nil file or directory positional arg
--- @field test_path_pattern string|nil regex against test file paths (--testPathPattern)
--- @field test_name_pattern string|nil regex against full test names (--testNamePattern)

M.active = nil -- { handle, cancelled } for the in-flight job, if any
local queued = nil -- { opts, on_done } for the single most-recent queued request

--- Run jest asynchronously.
--- @param opts JestRunOpts
--- @param on_done fun(decoded: table|nil, err: string|nil)
function M.run(opts, on_done)
  opts = opts or {}

  local policy = require('jest.config').options.concurrent_runs or 'cancel'

  if M.active then
    if policy == 'queue' then
      -- only the latest request is kept; an older queued one is superseded
      queued = { opts = opts, on_done = on_done }
      return
    elseif policy == 'cancel' then
      M.active.cancelled = true
      if M.active.handle then
        pcall(function() M.active.handle:kill('sigterm') end)
      end
      M.active = nil
    end
    -- 'allow': fall through and spawn a second, concurrent job
  end

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

  local job_state = { cancelled = false }

  local function finish(decoded, err)
    if not job_state.cancelled then
      on_done(decoded, err)
    end
    local next_req = queued
    if next_req then
      queued = nil
      M.run(next_req.opts, next_req.on_done)
    end
  end

  -- vim.system's on_exit runs in a fast event context: vim.fn.*/vim.cmd
  -- calls are not allowed there and throw, so everything must go through
  -- vim.schedule before touching them.
  local ok, err_or_handle = pcall(vim.system, cmd, { cwd = root, text = true }, function(res)
    vim.schedule(function()
      if M.active == job_state then
        M.active = nil
      end

      -- jest exits non-zero when tests fail; that's not a runner error, only
      -- treat it as one if we truly got no output file to parse.
      local read_ok, contents = pcall(vim.fn.readfile, outfile)
      if not read_ok or #contents == 0 then
        local msg = res.stderr ~= '' and res.stderr or ('jest exited with code ' .. res.code)
        vim.fn.delete(outfile)
        finish(nil, vim.trim(msg))
        return
      end
      local decoded_ok, decoded = pcall(vim.json.decode, table.concat(contents, '\n'))
      vim.fn.delete(outfile)
      if not decoded_ok then
        finish(nil, 'failed to decode jest --json output: ' .. tostring(decoded))
        return
      end
      finish(decoded, nil)
    end)
  end)

  if ok then
    job_state.handle = err_or_handle
    M.active = job_state
  else
    vim.fn.delete(outfile)
    vim.schedule(function()
      on_done(nil, 'failed to start jest (' .. table.concat(cmd, ' ') .. '): ' .. tostring(err_or_handle))
    end)
  end
end

return M
