local M = {}

local function rename_file()
  local old_uri = vim.uri_from_bufnr(0)
  local old_path = vim.api.nvim_buf_get_name(0)
  vim.ui.input({ prompt = 'New name: ', default = vim.fn.fnamemodify(old_path, ':t') }, function(new_name)
    if not new_name or new_name == '' then
      return
    end
    local new_path = vim.fn.fnamemodify(old_path, ':h') .. '/' .. new_name
    local new_uri = vim.uri_from_fname(new_path)

    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0, name = 'vtsls' })) do
      client:exec_cmd({
        command = 'vtsls.commands.renameFile',
        arguments = { old_uri, new_uri },
      }, { bufnr = 0 })
    end

    vim.fn.rename(old_path, new_path)
    vim.cmd.edit(new_path)
    vim.cmd('bwipeout! ' .. vim.fn.fnameescape(old_path))
  end)
end

function M.setup()
  -- Add blink.cmp capabilities to every server's config
  vim.lsp.config('*', {
    capabilities = require('blink.cmp').get_lsp_capabilities(),
  })

  vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = 'Next diagnostic' })
  vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = 'Prev diagnostic' })
  vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic' })
  vim.keymap.set('n', '<leader>lr', '<cmd>lsp restart<cr>', { desc = 'Restart LSP' })

  -- This is where you enable features that only work
  -- if there is a language server active in the file
  vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
      local opts = { buffer = event.buf }

      vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
      vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
      vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
      vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
      vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
      vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
      vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
      vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
      vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
      vim.keymap.set('n', 'gO', function()
        vim.lsp.buf.code_action({
          context = { only = { 'source.organizeImports' }, diagnostics = {} },
          apply = true,
        })
      end, vim.tbl_extend('force', opts, { desc = 'Organize imports' }))
      vim.keymap.set('i', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)

      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client then
        if client:supports_method('textDocument/inlayHint') then
          vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
        end
        if client.name == 'vtsls' then
          vim.keymap.set('n', '<leader>cR', rename_file, vim.tbl_extend('force', opts, { desc = 'Rename file' }))
        end
      end
    end,
  })

  vim.keymap.set('n', '<leader>uh', function()
    local bufnr = vim.api.nvim_get_current_buf()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
  end, { desc = 'Toggle inlay hints' })

  vim.lsp.enable({ 'vtsls', 'angularls', 'lua_ls', 'bashls', 'rust_analyzer' })
end

return M
