return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    options = {
      theme = 'nord', -- built into lualine
      globalstatus = true, -- one bar across the bottom, like VS Code
      component_separators = '',
      section_separators = '',
      disabled_filetypes = { statusline = { 'lazy' } },
    },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = { 'branch', 'diff' },
      lualine_c = { { 'filename', path = 1 }, 'diagnostics' },
      lualine_x = { 'encoding', { 'fileformat', icons_enabled = false }, 'filetype' },
      lualine_y = {
        function() return ('Ln %d, Col %d'):format(vim.fn.line('.'), vim.fn.virtcol('.')) end,
      },
      lualine_z = { 'progress' },
    },
    extensions = { 'nvim-tree', 'trouble', 'lazy', 'fugitive', 'nvim-dap-ui' },
  },
}
