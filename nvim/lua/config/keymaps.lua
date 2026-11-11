-- Editor-wide keymaps. Plugin keymaps live with their plugin in lua/plugins/.
-- Toggles (<leader>u…) are in plugins/snacks.lua.
local map = vim.keymap.set

map("n", "<C-d>", "<C-d>zz", { desc = "Half page down, centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up, centered" })
map("n", "n", "nzz", { desc = "Next search result, centered" })
map("n", "N", "Nzz", { desc = "Prev search result, centered" })

map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- move between windows (tree, editor, terminal, chat) without <C-w>;
-- in the terminal this replaces the shell's <C-l> clear-screen
map({ "n", "t" }, "<C-h>", "<cmd>wincmd h<cr>", { desc = "Window left" })
map({ "n", "t" }, "<C-j>", "<cmd>wincmd j<cr>", { desc = "Window down" })
map({ "n", "t" }, "<C-k>", "<cmd>wincmd k<cr>", { desc = "Window up" })
map({ "n", "t" }, "<C-l>", "<cmd>wincmd l<cr>", { desc = "Window right" })

map("x", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down", silent = true })
map("x", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up", silent = true })
map("x", "<", "<gv", { desc = "Indent left, keep selection" })
map("x", ">", ">gv", { desc = "Indent right, keep selection" })
map("x", "<leader>p", '"_dP', { desc = "Paste over selection, keep register" })

map({ "n", "i", "x" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
