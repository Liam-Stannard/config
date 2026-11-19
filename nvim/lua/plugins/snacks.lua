return {
  'folke/snacks.nvim',
  lazy = false,
  opts = {
    terminal = {
      win = {
        -- the terminal opens with botright, under every window; move the file
        -- tree back to full height on the left, like VS Code's sidebar.
        -- Set vim.g.tree_full_height = false in config/set.lua to turn it off.
        on_win = function()
          if not vim.g.tree_full_height then return end
          local tree = require('nvim-tree.api').tree.winid()
          if not tree then return end
          local width = vim.api.nvim_win_get_width(tree)
          vim.api.nvim_win_call(tree, function() vim.cmd('wincmd H') end)
          vim.api.nvim_win_set_width(tree, width)
        end,
      },
    },
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
