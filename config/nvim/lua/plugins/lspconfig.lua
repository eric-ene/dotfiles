return {
	"neovim/nvim-lspconfig",
	config = function()
		vim.diagnostic.config({
			virtual_text = true,
		})

		local lspconfig = require("lspconfig")

		lspconfig.rust_analyzer.setup({
			settings = {
				["rust-analyzer"] = {
					["cargo"] = {
						["features"] = "all",
					},
				},
			},
		})

		lspconfig.omnisharp.setup({
			cmd = {
				"OmniSharp",
				"-z",
				"--hostPID",
				vim.fn.getpid(),
				"DotNet:enablePackageRestore=false",
				"--encoding",
				"utf-8",
				"--languageserver",
			},
		})

		lspconfig.ts_ls.setup({})
		lspconfig.html.setup({})

		lspconfig.gopls.setup({})

		lspconfig.lua_ls.setup({
			settings = {
				Lua = {
					runtime = { version = "LuaJIT" },
					diagnostics = {
						globals = {
							"vim",
							"require",
						},
					},
					workspace = {
						library = vim.api.nvim_get_runtime_file("", true),
					},
					telemetry = {
						enable = false,
					},
				},
			},
		})
	end,
}
