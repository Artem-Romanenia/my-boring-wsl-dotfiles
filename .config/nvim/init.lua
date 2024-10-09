require("plugins")
require("remap")
require("Comment")
require("treesitter")
require("lsp")

vim.o.number = true
vim.o.relativenumber = true
vim.o.list = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

vim.cmd.colorscheme "catppuccin-mocha"
