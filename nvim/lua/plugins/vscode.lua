return {
  'Mofiqul/vscode.nvim',
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    require('vscode').setup({
      style = 'dark', -- VS Code "Dark Modern"
      italic_comments = true,
      underline_links = true,
    })
    vim.cmd.colorscheme('vscode')
  end,
}
