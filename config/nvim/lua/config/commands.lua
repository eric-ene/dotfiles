local bufclose = function(opts)
	local bufnr = vim.fn.bufnr()
	local listed = vim.fn.getbufinfo({ buflisted = 1 })

	if #listed == 1 and listed[1].bufnr == bufnr then
		vim.cmd("bd")
		vim.cmd("Dashboard")
		return
	end

	vim.cmd("bd" .. (opts.args ~= "" and " " .. opts.args or ""))
end

vim.api.nvim_create_user_command("Bufclose", bufclose, { nargs = "*", bang = true, complete = "buffer" })
