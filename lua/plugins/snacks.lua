return {
  'folke/snacks.nvim',
  lazy = false,
  opts = {
    terminal = {},
  },
  keys = {
    {
      [[<c-\>]],
      function() Snacks.terminal.toggle() end,
      desc = 'Toggle terminal',
      mode = { 'n', 't' },
    },
  },
}
