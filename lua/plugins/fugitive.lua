return {
  'tpope/vim-fugitive',
  keys = {
    { '<leader>gs', '<cmd>Git<cr>', desc = 'Git status' },
    { '<leader>gc', '<cmd>Git commit<cr>', desc = 'Git commit' },
    { '<leader>gp', '<cmd>Git push<cr>', desc = 'Git push' },
    { '<leader>gP', '<cmd>Git pull<cr>', desc = 'Git pull' },
    { '<leader>gb', '<cmd>Git blame<cr>', desc = 'Git blame' },
    { '<leader>gd', '<cmd>Gdiffsplit<cr>', desc = 'Git diff split' },
    { '<leader>gl', '<cmd>Git log<cr>', desc = 'Git log' },
    { '<leader>gw', '<cmd>Gwrite<cr>', desc = 'Git stage current file' },
    { '<leader>go', '<cmd>Gread<cr>', desc = 'Git checkout current file' },
  },
}
