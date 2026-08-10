return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-neotest/nvim-nio',
    'nvim-neotest/neotest-jest',
  },
  keys = {
    { '<leader>tt', function() require('neotest').run.run() end, desc = 'Run nearest test' },
    { '<leader>tf', function() require('neotest').run.run(vim.fn.expand('%')) end, desc = 'Run test file' },
    { '<leader>to', function() require('neotest').output.open({ enter = true }) end, desc = 'Toggle test output' },
    { '<leader>ts', function() require('neotest').summary.toggle() end, desc = 'Toggle test summary' },
  },
  config = function()
    require('neotest').setup({
      adapters = {
        require('neotest-jest')({
          jestCommand = 'npx jest',
        }),
      },
    })
  end,
}
