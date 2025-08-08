local map = vim.keymap

local mode = { "n" }

map.set(mode, "<Leader>q", "<cmd>Bufclose<cr>")
map.set(mode, "q:", "<nop>")

map.set(mode, "<Leader>[", "<cmd>bNext<cr>")
map.set(mode, "<Leader>]", "<cmd>bnext<cr>")

map.set(mode, "<Leader>t", "<cmd>Neotree toggle<cr>")
map.set(mode, "<C-h>", "<C-w>h")
map.set(mode, "<C-l>", "<C-w>l")
map.set(mode, "<C-j>", "<C-w>j")
map.set(mode, "<C-k>", "<C-w>k")

map.set(mode, "<Leader>c", "<Plug>(comment_toggle_linewise_current)")

map.set(mode, "<Leader>f", "<cmd>Telescope find_files<cr>")
map.set(mode, "<Leader>g", "<cmd>Telescope live_grep<cr>")
map.set(mode, "<Leader>d", "<cmd>Telescope current_buffer_fuzzy_find<cr>")

map.set(mode, "<Leader>r", vim.lsp.buf.rename)
map.set(mode, "<Leader>a", vim.lsp.buf.code_action)

mode = { "v" }

map.set(mode, "<Leader>c", "<Plug>(comment_toggle_linewise_visual)")
