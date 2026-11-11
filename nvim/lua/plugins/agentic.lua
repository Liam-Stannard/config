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
  config = function(_, opts)
    require('agentic').setup(opts)

    -- With no editor window to reuse (e.g. only the file tree beside the chat),
    -- agentic opens one with `topleft vsplit`, which lands left of the tree and
    -- squeezes it. Move that window to just right of the tree and restore the
    -- tree's and chat's widths. Patches an internal method, so re-check this
    -- after updating agentic.nvim.
    local ChatWidget = require('agentic.ui.chat_widget')
    local open_editor_window = ChatWidget.open_editor_window
    function ChatWidget:open_editor_window(bufnr)
      local winid = open_editor_window(self, bufnr)
      local tree = require('nvim-tree.api').tree.winid({ tabpage = self:get_visible_tab_id() })
      if not winid or not tree or self.current_position == 'bottom' then
        return winid
      end

      vim.fn.win_splitmove(winid, tree, { vertical = true, rightbelow = true })
      vim.wo[winid].winfixwidth = false -- split from the chat, so it inherited the chat's fixed width
      local chat = self.win_nrs.chat
      if chat and vim.api.nvim_win_is_valid(chat) then
        local width = require('agentic.ui.widget_layout').calculate_width(require('agentic.config').windows.width)
        vim.api.nvim_win_set_width(chat, width)
      end
      require('nvim-tree.api').tree.resize() -- back to view.width
      return winid
    end
  end,
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
