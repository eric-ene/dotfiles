if vim.g.vscode then
	return
end

vim.g.mapleader = "<Space>"
require("config.lazy")

local vim_opts = vim.opt

vim_opts.expandtab = true
vim_opts.shiftwidth = 2
vim_opts.tabstop = 2
vim_opts.number = true
vim_opts.relativenumber = true

vim_opts.laststatus = 3

vim_opts.clipboard = "unnamed"

vim.cmd("colorscheme kanagawa-dragon")

require("config.commands")
require("config.bindings")
require("config.godot")
