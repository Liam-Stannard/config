return {
  'folke/snacks.nvim',
  lazy = false,
  opts = {
    terminal = {},
    indent = { scope = { enabled = true } }, -- highlight the current block's guide
    scroll = {}, -- smooth scrolling
    words = {},
    -- show images in buffers and inline in markdown (kitty graphics)
    image = {
      wo = { cursorline = false }, -- the current-line highlight shows through transparent pixels
    },
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
