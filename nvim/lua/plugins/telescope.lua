return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" }, -- faster, better-ranked sorting
	},
	config = function()
		require("telescope").setup({})
		require("telescope").load_extension("fzf")
	end,
	keys = {
		{
			"<leader>fr",
			function()
				require("telescope.builtin").resume()
			end,
			desc = "Resume last picker",
		},
		{
			"<leader>fo",
			function()
				require("telescope.builtin").oldfiles({ only_cwd = true })
			end,
			desc = "Recent files",
		},
		{
			"<leader>f.",
			function()
				require("telescope.builtin").grep_string()
			end,
			mode = { "n", "x" },
			desc = "Grep word under cursor",
		},
		{
			"<leader>fh",
			function()
				require("telescope.builtin").help_tags()
			end,
			desc = "Help tags",
		},
		{
			"<leader>ff",
			function()
				require("telescope.builtin").find_files()
			end,
			desc = "Find files",
		},
		{
			"<leader>fg",
			function()
				require("telescope.builtin").live_grep()
			end,
			desc = "Live grep",
		},
		{
			"<leader>fb",
			function()
				require("telescope.builtin").buffers()
			end,
			desc = "Buffers",
		},
		{
			"<leader>fs",
			function()
				require("telescope.builtin").lsp_document_symbols()
			end,
			desc = "Document symbols",
		},
		{
			"<leader>fw",
			function()
				require("telescope.builtin").lsp_dynamic_workspace_symbols()
			end,
			desc = "Workspace symbols",
		},
	},
}
