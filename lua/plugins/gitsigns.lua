return {
  'lewis6991/gitsigns.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = 'eol',
      delay = 300,
      ignore_whitespace = false,
    },
    current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
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

      vim.keymap.set('n', '<leader>gB', function()
        gitsigns.blame_line({ full = true })
      end, vim.tbl_extend('force', opts, { desc = 'Git blame line (full)' }))
      vim.keymap.set(
        'n',
        '<leader>gtb',
        gitsigns.toggle_current_line_blame,
        vim.tbl_extend('force', opts, { desc = 'Toggle current-line blame' })
      )
    end,
  },
}
