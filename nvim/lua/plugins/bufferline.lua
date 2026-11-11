return {
  'akinsho/bufferline.nvim',
  version = '*',
  event = 'VeryLazy',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  keys = {
    { '<S-h>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Previous tab' },
    { '<S-l>', '<cmd>BufferLineCycleNext<cr>', desc = 'Next tab' },
    { '<leader>bd', function() Snacks.bufdelete() end, desc = 'Close tab (keep window layout)' },
    { '<leader>bo', function() Snacks.bufdelete.other() end, desc = 'Close other tabs' },
    { '<leader>bp', '<cmd>BufferLineTogglePin<cr>', desc = 'Pin tab' },
  },
  opts = {
    options = {
      -- Snacks.bufdelete keeps the window open, like closing a tab in VS Code
      close_command = function(n) Snacks.bufdelete(n) end,
      right_mouse_command = function(n) Snacks.bufdelete(n) end,
      diagnostics = 'nvim_lsp',
      always_show_bufferline = true,
      separator_style = 'slant',
      offsets = {
        { filetype = 'NvimTree', text = 'EXPLORER', text_align = 'left', separator = true },
      },
    },
  },
}
