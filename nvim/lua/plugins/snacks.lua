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
  init = function()
    -- which-key shows each toggle's current state
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
        Snacks.toggle.option('wrap', { name = 'Line wrap' }):map('<leader>uw')
        Snacks.toggle.option('spell', { name = 'Spell check' }):map('<leader>us')
        Snacks.toggle.line_number():map('<leader>ul')
        Snacks.toggle.diagnostics():map('<leader>ud')
        Snacks.toggle.inlay_hints():map('<leader>uh')
      end,
    })
  end,
  keys = {
    {
      [[<c-\>]],
      function() Snacks.terminal.toggle() end,
      desc = 'Toggle terminal',
      mode = { 'n', 't' },
    },
  },
}
