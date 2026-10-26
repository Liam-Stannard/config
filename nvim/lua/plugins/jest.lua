return {
  -- local-only module (lua/jest/), not an installable plugin; `dir` just
  -- gives lazy.nvim a source so it can lazy-load on these keys.
  'jest.nvim',
  dir = vim.fn.stdpath('config') .. '/lua/jest',
  name = 'jest.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  -- keymaps are user-configurable (jest.config.options.keymaps), so they
  -- can't be declared statically here for lazy.nvim's `keys` trigger; load
  -- eagerly-ish instead, same as which-key.lua.
  event = 'VeryLazy',
  config = function()
    require('jest').setup({})
    local jest = require('jest')
    local km = require('jest.config').options.keymaps

    local function map(lhs, fn, desc)
      if lhs then
        vim.keymap.set('n', lhs, fn, { desc = desc })
      end
    end

    map(km.run_file, jest.run_file, 'Jest: run file')
    map(km.run_dir, jest.run_dir, 'Jest: run directory')
    map(km.run_nearest, jest.run_nearest, 'Jest: run nearest test')
    map(km.run_last, jest.run_last, 'Jest: rerun last')
    map(km.reopen, jest.reopen, 'Jest: reopen last results')
    map(km.pick, jest.pick, 'Jest: pick file/directory')
    map(km.trouble, jest.trouble, 'Jest: last results in Trouble')
    map(km.toggle_summary, jest.toggle_summary, 'Jest: toggle summary window')

    vim.api.nvim_create_user_command('JestFile', jest.run_file, {})
    vim.api.nvim_create_user_command('JestDir', jest.run_dir, {})
    vim.api.nvim_create_user_command('JestNearest', jest.run_nearest, {})
    vim.api.nvim_create_user_command('JestLast', jest.run_last, {})
    vim.api.nvim_create_user_command('JestReopen', jest.reopen, {})
    vim.api.nvim_create_user_command('JestPick', jest.pick, {})
    vim.api.nvim_create_user_command('JestTrouble', jest.trouble, {})
    vim.api.nvim_create_user_command('JestSummary', jest.toggle_summary, {})
  end,
}
