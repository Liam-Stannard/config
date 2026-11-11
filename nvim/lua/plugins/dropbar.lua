-- VS Code-style breadcrumbs (path › symbol) in each window's winbar.
-- The default enable() skips special buffers (tree, Trouble, terminals, chat).
return {
  'Bekaboo/dropbar.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  keys = {
    { '<leader>;', function() require('dropbar.api').pick() end, desc = 'Pick breadcrumb' },
  },
  opts = {},
}
