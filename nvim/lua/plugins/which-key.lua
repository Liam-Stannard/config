return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    spec = {
      { "<leader>b", group = "Buffers" },
      { "<leader>c", group = "Code" },
      { "<leader>d", group = "Debug" },
      { "<leader>e", group = "Explorer" },
      { "<leader>f", group = "Find" },
      { "<leader>g", group = "Git" },
      { "<leader>gt", group = "Git toggle" },
      { "<leader>h", group = "Hunks" },
      { "<leader>i", group = "AI (Agentic)" },
      { "<leader>j", group = "Harpoon" },
      { "<leader>l", group = "LSP" },
      { "<leader>m", group = "Markdown" },
      { "<leader>n", group = "Npm" },
      { "<leader>q", group = "Sessions" },
      { "<leader>s", group = "Search / replace" },
      { "<leader>t", group = "Test" },
      { "<leader>u", group = "Toggle" },
      { "<leader>x", group = "Diagnostics / lists (Trouble)" },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },

  },
}
