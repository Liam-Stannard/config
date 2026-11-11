-- Select and jump by syntax node: daf deletes a function, cia changes an
-- argument, ]m jumps to the next function. Avoids ]c (gitsigns hunks) and the
-- built-in ]a / ]t.
local function select(query)
	return function()
		require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects")
	end
end

local function move(fn, query)
	return function()
		require("nvim-treesitter-textobjects.move")[fn](query, "textobjects")
	end
end

local xo = { "x", "o" }
local nxo = { "n", "x", "o" }

return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	branch = "main", -- matches nvim-treesitter's main branch
	init = function()
		-- these ftplugins map ]] / ]m themselves, which would shadow the moves below
		vim.g.no_python_maps = true
		vim.g.no_rust_maps = true
	end,
	opts = {
		select = {
			lookahead = true, -- jump forward to the next object if not inside one
			-- whole lines, so daf doesn't leave an indented blank line behind
			selection_modes = { ["@function.outer"] = "V", ["@class.outer"] = "V" },
		},
		move = { set_jumps = true },
	},
	keys = {
		{ "af", select("@function.outer"), mode = xo, desc = "a function" },
		{ "if", select("@function.inner"), mode = xo, desc = "inner function" },
		{ "ac", select("@class.outer"), mode = xo, desc = "a class" },
		{ "ic", select("@class.inner"), mode = xo, desc = "inner class" },
		{ "aa", select("@parameter.outer"), mode = xo, desc = "a parameter" },
		{ "ia", select("@parameter.inner"), mode = xo, desc = "inner parameter" },
		{ "ao", select("@loop.outer"), mode = xo, desc = "a loop" },
		{ "io", select("@loop.inner"), mode = xo, desc = "inner loop" },
		{ "a?", select("@conditional.outer"), mode = xo, desc = "a conditional" },
		{ "i?", select("@conditional.inner"), mode = xo, desc = "inner conditional" },

		{ "]m", move("goto_next_start", "@function.outer"), mode = nxo, desc = "Next function start" },
		{ "]M", move("goto_next_end", "@function.outer"), mode = nxo, desc = "Next function end" },
		{ "[m", move("goto_previous_start", "@function.outer"), mode = nxo, desc = "Previous function start" },
		{ "[M", move("goto_previous_end", "@function.outer"), mode = nxo, desc = "Previous function end" },
		{ "]]", move("goto_next_start", "@class.outer"), mode = nxo, desc = "Next class start" },
		{ "[[", move("goto_previous_start", "@class.outer"), mode = nxo, desc = "Previous class start" },
	},
}
