return {
  'folke/snacks.nvim',
  lazy = false,
  opts = {
    terminal = {},
    indent = {},
    words = {},
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
