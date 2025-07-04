vim.g.mapleader = "<Space>"
require("config.lazy")

local vim_opts = vim.opt

vim_opts.expandtab = true
vim_opts.shiftwidth = 2
vim_opts.tabstop = 2
vim_opts.number = true
vim_opts.relativenumber = true

vim.cmd("colorscheme kanagawa-dragon")

require("config.bindings")
