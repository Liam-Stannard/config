return {
  'MeanderingProgrammer/render-markdown.nvim',
  ft = { 'markdown' },
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
  opts = {},
  keys = {
    { '<leader>mr', '<cmd>RenderMarkdown toggle<cr>', desc = 'Toggle markdown rendering', ft = 'markdown' },
  },
}
