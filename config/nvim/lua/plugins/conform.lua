return {
	"stevearc/conform.nvim",
	opts = function(_, opts)
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*",
			callback = function(args)
				require("conform").format({ bufnr = args.buf })
			end,
		})

		opts.formatters = {
			csharpier = {
				command = "csharpier",
				args = { "format" },
			},
		}

		local formatters = {
			lua = { "stylua" },
			rust = { "rustfmt", lsp_format = "fallback" },
			javascript = { "prettier" },
			typescript = { "prettier" },
			javascriptreact = { "prettier" },
			typescriptreact = { "prettier" },
			html = { "html_beautify" },
			cs = { "csharpier" },
		}

		opts.formatters_by_ft = formatters
	end,
}
