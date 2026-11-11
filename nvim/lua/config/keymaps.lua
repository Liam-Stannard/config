-- Editor-wide keymaps. Plugin keymaps live with their plugin in lua/plugins/.
local map = vim.keymap.set
local opt = vim.opt

map("n", "<C-c>", function()
  local enabled = not opt.number:get()
  opt.number = enabled
  opt.relativenumber = enabled
end, { desc = "Toggle line numbers" })

map("n", "<C-d>", "<C-d>zz", { desc = "Half page down, centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up, centered" })
map("n", "n", "nzz", { desc = "Next search result, centered" })
map("n", "N", "Nzz", { desc = "Prev search result, centered" })

map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- move between windows (tree, editor, terminal, chat) without <C-w>;
-- in the terminal this replaces the shell's <C-l> clear-screen
for key, dir in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  map({ "n", "t" }, "<C-" .. key .. ">", "<cmd>wincmd " .. key .. "<cr>", { desc = "Window " .. dir })
end

map("x", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down", silent = true })
map("x", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up", silent = true })
map("x", "<", "<gv", { desc = "Indent left, keep selection" })
map("x", ">", ">gv", { desc = "Indent right, keep selection" })
map("x", "<leader>p", '"_dP', { desc = "Paste over selection, keep register" })

map({ "n", "i", "x" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
