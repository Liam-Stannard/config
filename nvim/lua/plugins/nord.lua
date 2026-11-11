return {
  'gbprod/nord.nvim',
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    require('nord').setup({
      styles = { comments = { italic = true } },
    })
    vim.cmd.colorscheme('nord')
  end,
}
