return {
  'carlos-algms/agentic.nvim',
  opts = {
    provider = 'claude-agent-acp',
    acp_providers = {
      -- Unofficial GitLab Duo bridge (gitlab.com/reprazent/gitlab-duo-acp),
      -- installed as a release binary in ~/.local/bin. Switch to it inside
      -- the chat with <localleader>s. Both env vars are set per environment
      -- in the shell that launches nvim, never in this repo.
      ['gitlab-duo-acp'] = {
        command = 'gitlab-duo-acp',
        args = { 'start' },
        env = {
          GITLAB_URL = os.getenv('GITLAB_URL'),
          GITLAB_AUTH_TOKEN = os.getenv('GITLAB_AUTH_TOKEN'),
        },
      },
    },
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
