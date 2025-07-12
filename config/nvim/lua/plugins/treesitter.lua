return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	opts = { modules = { highlight = { enable = true }, autotag = { enable = true } } },
}
