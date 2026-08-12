local M = {}

M.defaults = {
  -- override the package manager entirely, e.g. { 'yarn' } (a trailing
  -- "run <script>" is appended automatically)
  npm_cmd = nil,

  -- project root detection (used to find package.json and resolve the
  -- package manager)
  root_pattern = 'package.json',
  -- optional override: function(file) -> root_dir|nil; takes precedence
  -- over root_pattern when it returns a non-nil value
  root_dir = nil,

  notify = {
    on_start = true, -- "Running: ..." message when a script starts
    on_error = true, -- missing package.json/script, spawn failures, non-zero exit
  },

  -- persistent terminal output panel
  output = {
    position = 'right', -- 'left'|'right'|'top'|'bottom'
    width = 80,
    height = 15,
    -- 'never': manual toggle only
    -- 'on_start': open as soon as a script starts (default; scripts are
    --   often long-running, so seeing output immediately matters more than
    --   for jest's buffered results)
    -- 'always': same as 'on_start' (no distinct "on_complete" moment here)
    auto_open = 'on_start',
  },

  -- set any entry to false/nil to disable that keymap
  keymaps = {
    pick = '<leader>np',
    last = '<leader>nl',
    stop = '<leader>nx',
    toggle_output = '<leader>no',

    -- bind specific npm-scripts entries directly to a key, e.g.
    -- { lint = '<leader>nl' } runs `npm run lint` (last one wins if it
    -- collides with another keymap above, same as any vim.keymap.set).
    -- Resolved against whichever project the buffer under the cursor
    -- belongs to at press-time, not the project active when Neovim started.
    scripts = {},
  },
}

M.options = vim.deepcopy(M.defaults)

function M.setup(opts)
  M.options = vim.tbl_deep_extend('force', vim.deepcopy(M.defaults), opts or {})
end

return M
