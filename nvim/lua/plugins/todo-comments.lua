-- Highlights TODO / FIXME / HACK / NOTE comments and lists them.
return {
  'folke/todo-comments.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    -- replaces the built-in ]t / [t tag jumps
    { ']t', function() require('todo-comments').jump_next() end, desc = 'Next todo comment' },
    { '[t', function() require('todo-comments').jump_prev() end, desc = 'Previous todo comment' },
    { '<leader>xt', '<cmd>Trouble todo toggle<cr>', desc = 'Todos (Trouble)' },
    { '<leader>ft', '<cmd>TodoTelescope<cr>', desc = 'Find todos' },
  },
  opts = {
    signs = false, -- keep the gutter for diagnostics and git
  },
}
