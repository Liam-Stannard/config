return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'mason-org/mason.nvim' },
    { 'mason-org/mason-lspconfig.nvim' },
    { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
    { 'hrsh7th/nvim-cmp' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'L3MON4D3/LuaSnip' },
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

    -- code completion
    local cmp = require('cmp')

    cmp.setup({
      sources = {
        { name = 'nvim_lsp' },
      },
      mapping = cmp.mapping.preset.insert({
        -- Navigate between completion items
        ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = 'select' }),
        ['<C-n>'] = cmp.mapping.select_next_item({ behavior = 'select' }),

        -- `Enter` key to confirm completion
        ['<CR>'] = cmp.mapping.confirm({ select = false }),

        -- Ctrl+Space to trigger completion menu
        ['<C-Space>'] = cmp.mapping.complete(),

        -- Scroll up and down in the completion documentation
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
      }),
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body)
        end,
      },
    })
  end,
}
