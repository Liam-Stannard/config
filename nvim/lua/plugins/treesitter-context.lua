-- VS Code's "sticky scroll": pins the enclosing function/class header to the top.
return {
  'nvim-treesitter/nvim-treesitter-context',
  event = { 'BufReadPost', 'BufNewFile' },
  opts = {
    max_lines = 3,
    multiline_threshold = 1,
  },
}
