-- Project-wide search and replace in an editable buffer (ripgrep).
return {
  'MagicDuck/grug-far.nvim',
  cmd = 'GrugFar',
  keys = {
    { '<leader>sr', function() require('grug-far').open() end, desc = 'Search and replace' },
    {
      '<leader>sw',
      function() require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>') } }) end,
      desc = 'Search and replace word under cursor',
    },
    {
      '<leader>sw',
      function() require('grug-far').with_visual_selection() end,
      mode = 'x',
      desc = 'Search and replace selection',
    },
  },
  opts = {},
}
