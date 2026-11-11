return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    {
      '<leader>ja',
      function() require('harpoon'):list():add() end,
      desc = 'Harpoon add file',
    },
    {
      '<leader>jj',
      function()
        local harpoon = require('harpoon')
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      desc = 'Harpoon quick menu',
    },
    {
      '<leader>j1',
      function() require('harpoon'):list():select(1) end,
      desc = 'Harpoon to file 1',
    },
    {
      '<leader>j2',
      function() require('harpoon'):list():select(2) end,
      desc = 'Harpoon to file 2',
    },
    {
      '<leader>j3',
      function() require('harpoon'):list():select(3) end,
      desc = 'Harpoon to file 3',
    },
    {
      '<leader>j4',
      function() require('harpoon'):list():select(4) end,
      desc = 'Harpoon to file 4',
    },
  },
}
