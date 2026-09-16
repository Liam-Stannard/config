return {
  'carlos-algms/agentic.nvim',
  opts = {
    provider = 'claude-agent-acp',
  },
  keys = {
    {
      '<leader>ii',
      function() require('agentic').toggle() end,
      mode = { 'n', 'v' },
      desc = 'Toggle Agentic chat',
    },
    {
      '<leader>ia',
      function() require('agentic').add_selection_or_file_to_context() end,
      mode = { 'n', 'v' },
      desc = 'Add file or selection to Agentic context',
    },
    {
      '<leader>in',
      function() require('agentic').new_session() end,
      mode = { 'n', 'v' },
      desc = 'New Agentic session',
    },
  },
}
