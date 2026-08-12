return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup {
      hijack_directories = { auto_open = false },
    }

    local api = require("nvim-tree.api")
    local opts = { noremap = true, silent = true }

    local function collapse_node()
      local node = api.tree.get_node_under_cursor()
      if node and node.nodes and node.open then
        api.node.open.edit(node)
      end
    end

    local function expand_node()
      local node = api.tree.get_node_under_cursor()
      if node and node.nodes and not node.open then
        api.node.open.edit(node)
      end
    end

    vim.keymap.set("n", "<leader>bt", api.tree.toggle, vim.tbl_extend("force", opts, { desc = "Toggle file tree" }))
    vim.keymap.set("n", "<leader>bf", function()
      api.tree.find_file { open = true, focus = true }
    end, vim.tbl_extend("force", opts, { desc = "Find current file in tree" }))
    vim.keymap.set("n", "<leader>br", api.tree.reload, vim.tbl_extend("force", opts, { desc = "Refresh tree" }))

    vim.keymap.set("n", "<leader>bc", collapse_node, vim.tbl_extend("force", opts, { desc = "Collapse node under cursor" }))
    vim.keymap.set("n", "<leader>be", expand_node, vim.tbl_extend("force", opts, { desc = "Expand node under cursor" }))
    vim.keymap.set("n", "<leader>bC", api.tree.collapse_all, vim.tbl_extend("force", opts, { desc = "Collapse entire tree" }))
    vim.keymap.set("n", "<leader>bE", api.tree.expand_all, vim.tbl_extend("force", opts, { desc = "Expand entire tree" }))

    vim.keymap.set("n", "<leader>bb", api.marks.toggle, vim.tbl_extend("force", opts, { desc = "Toggle bookmark" }))
    vim.keymap.set("n", "<leader>bB", api.marks.clear, vim.tbl_extend("force", opts, { desc = "Clear all bookmarks" }))
    vim.keymap.set("n", "<leader>bm", api.marks.bulk.move, vim.tbl_extend("force", opts, { desc = "Move bookmarked files" }))
  end,
}
