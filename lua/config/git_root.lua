-- When nvim is started on a directory inside a git repository (e.g. `nvim .`
-- from a subfolder), reroot to the repository's top level so that nvim-tree,
-- telescope and friends all see the whole project. Runs during init, before
-- the directory buffer is loaded, so nvim-tree's hijack picks up the new arg.
local M = {}

function M.setup()
  local argv = vim.fn.argv()
  if #argv ~= 1 or vim.fn.isdirectory(argv[1]) ~= 1 then
    return
  end

  local dir = vim.fs.normalize(vim.fn.fnamemodify(argv[1], ':p'))
  local root = vim.fs.root(dir, '.git')
  if not root or root == dir then
    return
  end

  vim.cmd.cd(root)
  vim.cmd.args(vim.fn.fnameescape(root))

  -- The buffer for the original directory arg already exists; wipe it so it
  -- doesn't linger in the buffer list and re-hijack the tree on :bnext.
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.fs.normalize(vim.api.nvim_buf_get_name(buf)) == dir then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
end

return M
