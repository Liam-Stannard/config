return {
  'nvim-telescope/telescope.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    { '<leader>ff', function() require('telescope.builtin').find_files() end, desc = 'Find files' },
    { '<leader>fg', function() require('telescope.builtin').live_grep() end, desc = 'Live grep' },
    { '<leader>fb', function() require('telescope.builtin').buffers() end, desc = 'Buffers' },
    { '<leader>fs', function() require('telescope.builtin').lsp_document_symbols() end, desc = 'Document symbols' },
    { '<leader>fw', function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end, desc = 'Workspace symbols' },
    {
      '<leader>af',
      function()
        require('telescope.builtin').find_files({
          prompt_title = 'Angular Files',
          find_command = {
            'rg', '--files',
            '--glob', '*.ts',
            '--glob', '*.html',
            '--glob', '*.scss',
            '--glob', '!*.spec.ts',
          },
        })
      end,
      desc = 'Find Angular files (no specs)',
    },
    {
      '<leader>ag',
      function()
        require('telescope.builtin').live_grep({
          prompt_title = 'Grep Angular Files',
          glob_pattern = { '*.ts', '*.html', '*.scss', '!*.spec.ts' },
        })
      end,
      desc = 'Grep Angular files (no specs)',
    },
  },
}
