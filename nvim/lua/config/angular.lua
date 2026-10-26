local M = {}

local function stem(basename)
  return (basename:gsub('%.spec%.ts$', ''):gsub('%.ts$', ''):gsub('%.html$', ''):gsub('%.scss$', ''):gsub('%.css$', ''))
end

local function jump(suffix)
  local path = vim.api.nvim_buf_get_name(0)
  local dir = vim.fn.fnamemodify(path, ':h')
  local base = stem(vim.fn.fnamemodify(path, ':t'))
  local target = dir .. '/' .. base .. suffix

  if vim.uv.fs_stat(target) then
    vim.cmd.edit(target)
  else
    vim.notify('No sibling file: ' .. base .. suffix, vim.log.levels.WARN)
  end
end

function M.setup()
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'typescript', 'typescriptreact', 'html', 'scss', 'css' },
    callback = function(event)
      local opts = { buffer = event.buf }
      vim.keymap.set('n', '<leader>ac', function() jump('.ts') end, opts)
      vim.keymap.set('n', '<leader>at', function() jump('.spec.ts') end, opts)
      vim.keymap.set('n', '<leader>ah', function() jump('.html') end, opts)
      vim.keymap.set('n', '<leader>as', function() jump('.scss') end, opts)
    end,
  })
end

return M
