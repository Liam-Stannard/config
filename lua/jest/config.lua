local M = {}

M.defaults = {
  -- override jest command entirely, e.g. { 'yarn', 'jest' }
  jest_cmd = nil,
  extra_args = {},
  icons = { passed = '✓', failed = '✗', pending = '○', todo = '◌' },
}

M.options = vim.deepcopy(M.defaults)

function M.setup(opts)
  M.options = vim.tbl_deep_extend('force', vim.deepcopy(M.defaults), opts or {})
end

return M
