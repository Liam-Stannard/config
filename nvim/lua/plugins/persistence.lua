-- Per-directory sessions, saved on exit and restored on request.
return {
  'folke/persistence.nvim',
  event = 'BufReadPre',
  keys = {
    { '<leader>qs', function() require('persistence').load() end, desc = 'Restore session (this directory)' },
    { '<leader>qS', function() require('persistence').select() end, desc = 'Pick session' },
    { '<leader>ql', function() require('persistence').load({ last = true }) end, desc = 'Restore last session' },
    { '<leader>qd', function() require('persistence').stop() end, desc = "Don't save this session" },
  },
  init = function()
    -- side panels come back as empty buffers in a restored session, so close them first
    vim.api.nvim_create_autocmd('User', {
      pattern = 'PersistenceSavePre',
      callback = function()
        pcall(function() require('nvim-tree.api').tree.close() end)
        pcall(function() require('trouble').close() end)
        if package.loaded['dapui'] then
          require('dapui').close()
        end
      end,
    })
  end,
  opts = {},
}
