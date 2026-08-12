local M = {}

--- M.jobs[script] = { job_id, cancelled } for currently-active jobs only
M.jobs = {}
--- M.buffers[script] = bufnr, retained after a job exits so its output can
--- still be reviewed (unlike M.jobs, which only tracks in-flight runs)
M.buffers = {}

--- Run `script` via `cmd` (argv) in `cwd`, streaming into a fresh terminal
--- buffer. Kills any job already running for this script name first (jest's
--- 'cancel' policy, but scoped per script name so unrelated scripts, e.g.
--- `dev` and `test:watch`, can run side by side).
--- @param script string
--- @param cmd string[]
--- @param cwd string
--- @param on_exit fun(code: integer)
--- @return integer|nil bufnr, nil if the job failed to start
function M.run(script, cmd, cwd, on_exit)
  M.stop(script)
  local old_buf = M.buffers[script]

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].bufhidden = 'hide'
  vim.bo[bufnr].filetype = 'npm-output'

  local job_state = { cancelled = false }

  -- termopen needs `bufnr` to be current for the call; it doesn't need to
  -- be displayed in a window.
  local job_id = vim.api.nvim_buf_call(bufnr, function()
    return vim.fn.termopen(cmd, {
      cwd = cwd,
      -- on_exit runs in a fast event context: vim.fn.*/vim.cmd calls are
      -- not allowed there and throw, so everything must go through
      -- vim.schedule before touching them.
      on_exit = function(_, code)
        vim.schedule(function()
          if M.jobs[script] == job_state then
            M.jobs[script] = nil
          end
          if not job_state.cancelled then
            on_exit(code)
          end
        end)
      end,
    })
  end)

  if job_id <= 0 then
    pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
    vim.schedule(function() on_exit(-1) end)
    return nil
  end

  if old_buf and vim.api.nvim_buf_is_valid(old_buf) then
    pcall(vim.api.nvim_buf_delete, old_buf, { force = true })
  end

  job_state.job_id = job_id
  M.jobs[script] = job_state
  M.buffers[script] = bufnr
  return bufnr
end

--- @param script string
--- @return boolean stopped false if `script` wasn't running
function M.stop(script)
  local job = M.jobs[script]
  if not job then
    return false
  end
  job.cancelled = true
  pcall(vim.fn.jobstop, job.job_id)
  M.jobs[script] = nil
  return true
end

--- Stop every currently-running script.
function M.stop_all()
  for script in pairs(vim.deepcopy(M.jobs)) do
    M.stop(script)
  end
end

--- @param script string
--- @return integer|nil bufnr of `script`'s output, running or finished
function M.bufnr(script)
  local buf = M.buffers[script]
  if buf and vim.api.nvim_buf_is_valid(buf) then
    return buf
  end
  return nil
end

--- @param script string
--- @return boolean
function M.is_running(script)
  return M.jobs[script] ~= nil
end

return M
