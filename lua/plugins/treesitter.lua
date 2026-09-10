local langs = {
	"bash",
	"c",
	"elixir",
	"groovy",
	"html",
	"java",
	"javascript",
	"lua",
	"markdown",
	"markdown_inline",
	"python",
	"rust",
	"typescript",
	"vim",
	"vimdoc",
}

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	-- the main branch is a full rewrite and explicitly does not support lazy-loading
	lazy = false,
	build = ":TSUpdate",
	config = function()
		-- installs parsers *and* symlinks each language's queries into
		-- stdpath('data')/site/queries; a language left out of this list gets
		-- no nvim-treesitter queries at all. Runs asynchronously.
		require("nvim-treesitter").install(langs)

		vim.api.nvim_create_autocmd("FileType", {
			callback = function(ev)
				local lang = vim.treesitter.language.get_lang(ev.match)
				if not lang or not vim.list_contains(langs, lang) then
					return
				end
				-- pcall: install() is async, so on the first startup after a
				-- fresh install the parser may not exist yet.
				pcall(vim.treesitter.start, ev.buf, lang)
				vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
