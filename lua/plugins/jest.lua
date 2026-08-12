return {
  -- local-only module (lua/jest/), not an installable plugin; `dir` just
  -- gives lazy.nvim a source so it can lazy-load on these keys.
  'jest.nvim',
  dir = vim.fn.stdpath('config'),
  name = 'jest.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  keys = {
    { '<leader>tf', function() require('jest').run_file() end, desc = 'Jest: run file' },
    { '<leader>td', function() require('jest').run_dir() end, desc = 'Jest: run directory' },
    { '<leader>tn', function() require('jest').run_nearest() end, desc = 'Jest: run nearest test' },
    { '<leader>tl', function() require('jest').run_last() end, desc = 'Jest: rerun last' },
  },
  config = function()
    require('jest').setup({})

    vim.api.nvim_create_user_command('JestFile', function() require('jest').run_file() end, {})
    vim.api.nvim_create_user_command('JestDir', function() require('jest').run_dir() end, {})
    vim.api.nvim_create_user_command('JestNearest', function() require('jest').run_nearest() end, {})
    vim.api.nvim_create_user_command('JestLast', function() require('jest').run_last() end, {})
  end,
}
