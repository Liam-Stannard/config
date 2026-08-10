return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'mason-org/mason.nvim' },
    { 'mason-org/mason-lspconfig.nvim' },
    { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
    {
      'saghen/blink.cmp',
      version = '1.*',
      opts = {
        keymap = {
          preset = 'none',
          ['<C-p>'] = { 'select_prev', 'fallback' },
          ['<C-n>'] = { 'select_next', 'fallback' },
          ['<CR>'] = { 'select_and_accept', 'fallback' },
          ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
          ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
          ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
        },
        completion = { documentation = { auto_show = true } },
        signature = { enabled = true },
      },
    },
  },
  config = function()
    require('mason').setup({})
    require('mason-lspconfig').setup({
      ensure_installed = { 'vtsls', 'angularls', 'lua_ls', 'bashls', 'rust_analyzer' },
      automatic_enable = false,
    })
    require('mason-tool-installer').setup({
      ensure_installed = {
        'prettier', 'stylua', 'shfmt', 'eslint_d', 'js-debug-adapter',
        -- java: started via ftplugin/java.lua + nvim-jdtls rather than
        -- vim.lsp.enable(), so it lives here instead of mason-lspconfig's list
        'jdtls', 'java-debug-adapter', 'java-test', 'google-java-format',
      },
    })

    require('config.lsp').setup()
  end,
}
