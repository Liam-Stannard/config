-- Compare the branch the way the MR will: from the merge base with the
-- remote's default branch, against the files on disk (uncommitted edits
-- included, and editable with LSP).
local function diff_mr()
  local function ref(name)
    local out = vim.fn.systemlist({ 'git', 'rev-parse', '--abbrev-ref', name })[1]
    return vim.v.shell_error == 0 and out or nil
  end
  local target = ref('origin/HEAD') or ref('origin/main') or ref('origin/master')
  if not target then
    vim.notify('No origin default branch to compare against', vim.log.levels.WARN)
    return
  end
  -- diffview never lists untracked files against a commit: a new file shows
  -- up once it's added (`git add -N` is enough)
  vim.cmd('DiffviewOpen ' .. target .. '...HEAD --imply-local')
end

return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory', 'DiffviewClose' },
  keys = {
    { '<leader>gv', '<cmd>DiffviewOpen<cr>', desc = 'Diff uncommitted changes' },
    { '<leader>gV', diff_mr, desc = 'Diff branch as the MR will show it' },
    { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = 'File history' },
    { '<leader>gH', '<cmd>DiffviewFileHistory<cr>', desc = 'Repo history' },
    { '<leader>gq', '<cmd>DiffviewClose<cr>', desc = 'Close diff view' },
  },
  opts = {},
}
