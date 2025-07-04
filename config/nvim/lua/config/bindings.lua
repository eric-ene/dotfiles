local map = vim.keymap

local mode = { "n" }

map.set(mode, "<Leader>t", "<cmd>Neotree toggle<cr>")
map.set(mode, "<C-h>", "<C-w>h")
map.set(mode, "<C-l>", "<C-w>l")
map.set(mode, "<C-j>", "<C-w>j")
map.set(mode, "<C-k>", "<C-w>k")

map.set(mode, "<Leader>c", "<Plug>(comment_toggle_linewise_current)")

mode = { "v" }
map.set(mode, "<Leader>c", "<Plug>(comment_toggle_linewise_visual)")
