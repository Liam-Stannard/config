return {
  'mfussenegger/nvim-lint',
  event = { 'BufWritePost', 'BufReadPost', 'InsertLeave' },
  config = function()
    local lint = require('lint')

    lint.linters_by_ft = {
      typescript = { 'eslint_d' },
      typescriptreact = { 'eslint_d' },
      javascript = { 'eslint_d' },
      javascriptreact = { 'eslint_d' },
    }

    vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufEnter', 'InsertLeave' }, {
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
