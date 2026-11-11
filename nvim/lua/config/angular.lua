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

local function find_files()
  require('telescope.builtin').find_files({
    prompt_title = 'Angular Files',
    find_command = {
      'rg',
      '--files',
      '--glob',
      '*.ts',
      '--glob',
      '*.html',
      '--glob',
      '*.scss',
      '--glob',
      '!*.spec.ts',
      '--glob',
      '!*.po.ts',
      '--glob',
      '!*.cy.ts',
      '--glob',
      '!**/node_modules/**',
      '--glob',
      '!**/dist/**',
      '--glob',
      '!*.js',
      '--glob',
      '!*.svg',
      '--glob',
      '!*.txt',
      '--glob',
      '!*.md',
      '--glob',
      '!*.json',
      '--glob',
      '!*.sh',
    },
  })
end

local function live_grep()
  require('telescope.builtin').live_grep({
    prompt_title = 'Grep Angular Files',
    glob_pattern = {
      '*.ts',
      '*.html',
      '*.scss',
      '!*.spec.ts',
      '!*.po.ts',
      '!*.cy.ts',
      '!**/node_modules/**',
      '!**/dist/**',
      '!*.js',
      '!*.svg',
      '!*.txt',
      '!*.md',
      '!*.json',
      '!*.sh',
    },
  })
end

-- filetype-specific keymaps live on <localleader> (\), global ones on <leader>
function M.setup()
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'typescript', 'typescriptreact', 'html', 'scss', 'css' },
    callback = function(event)
      local opts = { buffer = event.buf }
      vim.keymap.set('n', '<localleader>c', function() jump('.ts') end, vim.tbl_extend('force', opts, { desc = 'Angular: go to .ts' }))
      vim.keymap.set('n', '<localleader>t', function() jump('.spec.ts') end, vim.tbl_extend('force', opts, { desc = 'Angular: go to .spec.ts' }))
      vim.keymap.set('n', '<localleader>h', function() jump('.html') end, vim.tbl_extend('force', opts, { desc = 'Angular: go to .html' }))
      vim.keymap.set('n', '<localleader>s', function() jump('.scss') end, vim.tbl_extend('force', opts, { desc = 'Angular: go to .scss' }))
      vim.keymap.set('n', '<localleader>f', find_files, vim.tbl_extend('force', opts, { desc = 'Angular: find files (no specs)' }))
      vim.keymap.set('n', '<localleader>g', live_grep, vim.tbl_extend('force', opts, { desc = 'Angular: grep files (no specs)' }))
    end,
  })
end

return M
