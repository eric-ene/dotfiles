return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*",
      callback = function(args)
        require("conform").format({bufnr = args.buf})
      end,
    })  

    local formatters = {
      lua = { "stylua" },
      rust = { "rustfmt", lsp_format = "fallback" }
    }

    opts.formatters_by_ft = formatters
  end
}
