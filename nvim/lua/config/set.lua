local opt = vim.opt

opt.termguicolors = true

vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")

opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.updatetime = 300

opt.modelines = 0
opt.number = true
opt.relativenumber = true -- current line shows its absolute number
opt.cursorline = true
opt.colorcolumn = "120" -- like VS Code's editor.rulers
opt.scrolloff = 8
opt.fillchars = { eob = " " } -- hide the ~ on lines past the end of the buffer
opt.winborder = "rounded" -- default border for floating windows (hover, signature help)
opt.ruler = true
opt.visualbell = false
opt.encoding = "utf-8"
opt.mouse = "a" -- clickable tabs, breadcrumbs and file tree

opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true

opt.hidden = true
opt.ttyfast = true
opt.laststatus = 3 -- single global statusline (lualine)
opt.showmode = false -- lualine shows the mode
opt.showcmd = true

opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.showmatch = true
opt.timeoutlen = 300

vim.keymap.set("n", "<C-c>", function()
  local enabled = not opt.number:get()
  opt.number = enabled
  opt.relativenumber = enabled
end, { desc = "Toggle line numbers" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down, centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up, centered" })
vim.keymap.set("n", "n", "nzz", { desc = "Next search result, centered" })
vim.keymap.set("n", "N", "Nzz", { desc = "Prev search result, centered" })
