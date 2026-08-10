local opt = vim.opt

opt.termguicolors = true

vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")
vim.cmd([[colorscheme tokyonight]])

opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.updatetime = 300

opt.modelines = 0
opt.number = true
opt.relativenumber = true
opt.ruler = true
opt.visualbell = false
opt.encoding = "utf-8"
opt.mouse = ""

opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true

opt.hidden = true
opt.ttyfast = true
opt.laststatus = 2
opt.showmode = true
opt.showcmd = true

opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.showmatch = true
opt.timeoutlen = 300
