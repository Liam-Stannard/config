local M = {}

M.defaults = {
  -- override jest command entirely, e.g. { 'yarn', 'jest' }
  jest_cmd = nil,
  extra_args = {},
  icons = { passed = '✓', failed = '✗', pending = '○', todo = '◌', running = '●' },
  -- rg --glob patterns used by jest.pick() to find test files
  test_glob = {
    '*.spec.ts', '*.spec.tsx', '*.spec.js', '*.spec.jsx',
    '*.test.ts', '*.test.tsx', '*.test.js', '*.test.jsx',
  },

  -- gutter icons showing each test's last-known status while reviewing a file
  signs = { enabled = true },

  -- Telescope results picker
  picker = {
    -- 'always': open after every run (default, current behavior)
    -- 'on_failure': only pop open when something failed
    -- 'never': don't auto-open; use jest.reopen()/:JestReopen manually
    auto_open = 'always',
    -- forwarded as the first argument to telescope's pickers.new(), e.g.
    -- { layout_strategy = 'vertical', layout_config = { height = 0.9 } }
    layout = {},
  },

  -- persistent results panel
  summary = {
    position = 'right', -- 'left'|'right'|'top'|'bottom'
    width = 60,
    height = 15,
    -- 'never': manual toggle only (default, current behavior)
    -- 'on_start': open as soon as a run begins, showing running/spinner state
    -- 'on_complete': open once results arrive, same as picker's 'always'
    -- 'always': both of the above
    auto_open = 'never',
  },

  notify = {
    on_start = true, -- "Running: ..." message when a run kicks off
    on_error = true, -- runner/decode failures (distinct from test failures)
  },

  -- project root detection (used to resolve the jest binary/cwd)
  root_pattern = 'package.json',
  -- optional override: function(file) -> root_dir|nil; takes precedence
  -- over root_pattern when it returns a non-nil value
  root_dir = nil,

  -- 'cancel' (default): kill an in-flight run and start the new one
  -- 'queue': wait for the in-flight run to finish, then run the latest
  --   request (not every request queued individually, just the most recent)
  -- 'allow': no guard; runs can overlap
  concurrent_runs = 'cancel',

  -- mirror failing tests into vim.diagnostic, in addition to the gutter
  -- icon; off by default since it'll visually compete with LSP diagnostics
  diagnostics = { enabled = false },

  -- set any entry to false/nil to disable that keymap
  keymaps = {
    run_file = '<leader>tf',
    run_dir = '<leader>td',
    run_nearest = '<leader>tn',
    run_last = '<leader>tl',
    reopen = '<leader>to',
    pick = '<leader>tp',
    trouble = '<leader>tt',
    toggle_summary = '<leader>ts',
  },
}

M.options = vim.deepcopy(M.defaults)

function M.setup(opts)
  M.options = vim.tbl_deep_extend('force', vim.deepcopy(M.defaults), opts or {})
end

return M
