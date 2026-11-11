-- AgenticChat is agentic.nvim's chat buffer, so its responses render too.
local file_types = { 'markdown', 'AgenticChat' }

return {
  'MeanderingProgrammer/render-markdown.nvim',
  ft = file_types,
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
  opts = {
    file_types = file_types,
  },
  keys = {
    { '<leader>mr', '<cmd>RenderMarkdown toggle<cr>', desc = 'Toggle markdown rendering', ft = file_types },
  },
}
