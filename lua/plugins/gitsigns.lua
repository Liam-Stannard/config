return {
  'lewis6991/gitsigns.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    on_attach = function(bufnr)
      local gitsigns = require('gitsigns')
      local opts = { buffer = bufnr }

      vim.keymap.set('n', ']c', function()
        if vim.wo.diff then
          return ']c'
        end
        vim.schedule(gitsigns.next_hunk)
        return '<Ignore>'
      end, vim.tbl_extend('force', opts, { expr = true }))

      vim.keymap.set('n', '[c', function()
        if vim.wo.diff then
          return '[c'
        end
        vim.schedule(gitsigns.prev_hunk)
        return '<Ignore>'
      end, vim.tbl_extend('force', opts, { expr = true }))

      vim.keymap.set('n', '<leader>hs', gitsigns.stage_hunk, opts)
      vim.keymap.set('n', '<leader>hr', gitsigns.reset_hunk, opts)
      vim.keymap.set('n', '<leader>hp', gitsigns.preview_hunk, opts)
    end,
  },
}
