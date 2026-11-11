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
    { '<leader>bl', '<cmd>BufferLineMoveNext<cr>', desc = 'Move tab right' },
    { '<leader>bh', '<cmd>BufferLineMovePrev<cr>', desc = 'Move tab left' },
    { '<leader>bj', '<cmd>BufferLinePick<cr>', desc = 'Pick tab' },
    { '<leader>bL', '<cmd>BufferLineCloseRight<cr>', desc = 'Close tabs to the right' },
    { '<leader>bH', '<cmd>BufferLineCloseLeft<cr>', desc = 'Close tabs to the left' },
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
