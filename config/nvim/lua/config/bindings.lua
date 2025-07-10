local map = vim.keymap

local mode = { "n" }

map.set(mode, "<Leader>t", "<cmd>Neotree toggle<cr>")
map.set(mode, "<C-h>", "<C-w>h")
map.set(mode, "<C-l>", "<C-w>l")
map.set(mode, "<C-j>", "<C-w>j")
map.set(mode, "<C-k>", "<C-w>k")

map.set(mode, "<Leader>c", "<Plug>(comment_toggle_linewise_current)")

map.set(mode, "<Leader>f", "<cmd>Telescope find_files<cr>")
map.set(mode, "<Leader>g", "<cmd>Telescope live_grep<cr>")
map.set(mode, "<Leader>d", "<cmd>Telescope current_buffer_fuzzy_find<cr>")

mode = { "v" }
map.set(mode, "<Leader>c", "<Plug>(comment_toggle_linewise_visual)")
