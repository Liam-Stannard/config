return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<F3>',
      function()
        require('conform').format({ async = true, lsp_fallback = true })
      end,
      mode = { 'n', 'x' },
      desc = 'Format buffer',
    },
  },
  opts = {
    formatters_by_ft = {
      typescript = { 'prettier' },
      typescriptreact = { 'prettier' },
      javascript = { 'prettier' },
      javascriptreact = { 'prettier' },
      html = { 'prettier' },
      css = { 'prettier' },
      scss = { 'prettier' },
      json = { 'prettier' },
      lua = { 'stylua' },
      sh = { 'shfmt' },
      rust = { 'rustfmt' },
      java = { 'google-java-format' },
    },
    format_on_save = {
      lsp_fallback = true,
      timeout_ms = 1000,
    },
  },
}
