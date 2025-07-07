local modes = {
	n = "NORMAL",
	i = "INSERT",
	v = "VISUAL",
	c = "COMMAND",
	r = "REPLACE",
}
local colors = {
	n = "oldWhite",
	i = "dragonGreen",
	v = "dragonViolet",
	c = "dragonRed",
	r = "dragonRed",
}

local pad = function(num)
	return {
		provider = function()
			return string.rep(" ", num)
		end,
	}
end

--- @alias loc "status" | "tabline"
--- @param loc loc
local modemeta = function(loc, opts)
	local redrawfunc = "redraw" .. loc

	return {
		init = function(self)
			self.mode = vim.fn.mode(1)
		end,
		update = {
			"ModeChanged",
			pattern = "*:*",
			callback = vim.schedule_wrap(function()
				vim.cmd(redrawfunc)
			end),
		},
		opts,
	}
end

--- @param loc loc
--- @param textprovider function
local modebackgroundmeta = function(textprovider, loc, opts)
	return modemeta(loc, {
		opts,
		provider = textprovider,
		hl = function(self)
			return { bg = colors[self.mode:sub(1, 1)], fg = "dragonBlack0" }
		end,
	})
end

--- @param loc loc
--- @param textprovider function
local modeforegroundmeta = function(textprovider, loc, opts)
	return modemeta(loc, {
		opts,
		provider = textprovider,
		hl = function(self)
			return { fg = colors[self.mode:sub(1, 1)] }
		end,
	})
end

return {
	"rebelot/heirline.nvim",
	lazy = false,
	dependencies = {
		"kanagawa",
	},
	opts = function(_, opts)
		vim.cmd("colorscheme kanagawa")
		vim.cmd("set noshowmode")
		local themecolors = require("kanagawa.colors").setup().palette
		require("heirline").load_colors(themecolors)

		local utils = require("heirline.utils")
		local conditions = require("heirline.conditions")
		local fmt = require("conform")

		-- local mode = {
		-- 	init = function(self)
		-- 		self.mode = vim.fn.mode(1)
		-- 	end,
		--
		-- 	provider = function(self)
		-- 		return " " .. modes[self.mode:sub(1, 1)]:sub(1, 3) .. " "
		-- 	end,
		--
		-- 	hl = function(self)
		-- 		return { bg = colors[self.mode:sub(1, 1)], fg = "dragonBlack0" }
		-- 	end,
		--
		-- 	update = {
		-- 		"ModeChanged",
		-- 		pattern = "*:*",
		-- 		callback = vim.schedule_wrap(function()
		-- 			vim.cmd("redrawstatus")
		-- 		end),
		-- 	},
		-- }

		-- local mode = modemeta("status", {
		-- 	provider = function(self)
		-- 		return " " .. modes[self.mode:sub(1, 1)]:sub(1, 3) .. " "
		-- 	end,
		--
		-- 	hl = function(self)
		-- 		return { bg = colors[self.mode:sub(1, 1)], fg = "dragonBlack0" }
		-- 	end,
		-- })

		local mode = modebackgroundmeta(function(self)
			return " " .. modes[self.mode:sub(1, 1)]:sub(1, 3) .. " "
		end, "tabline")

		local mode2 = modeforegroundmeta(function(self)
			return modes[self.mode:sub(1, 1)]:sub(1, 3)
		end, "status")

		local filenameinfo = {
			provider = function(self)
				local filepath = vim.fn.fnamemodify(self.filename, ":.")
				if filepath == "" then
					return "[ unnamed file ]"
				end

				if not conditions.width_percent_below(#filepath, 0.25) then
					filepath = vim.fn.pathshorten(filepath)
				end

				return filepath
			end,
		}

		local fileflags = {
			{
				condition = function()
					return vim.bo.modified
				end,
				provider = "[+]",
				hl = { fg = "dragonGreen" },
			},
			{
				condition = function()
					return not vim.bo.modifiable or vim.bo.readonly
				end,
				provider = "[x]",
				hl = { fg = "dragonRed" },
			},
		}

		local filetype = {
			provider = function()
				return " <" .. vim.bo.filetype .. "> "
			end,
			hl = function()
				return {
					fg = "dragonBlack0",
					bg = colors[vim.fn.mode(1):sub(1, 1)],
				}
			end,
		}

		local fileblock = {
			init = function(self)
				self.filename = vim.api.nvim_buf_get_name(0)
			end,
			{
				filenameinfo,
				pad(1),
				fileflags,
			},
		}

		local fill = {
			provider = "%=",
		}

		local rulers = {
			provider = "(%l:%c)/%L",
		}

		local lspinfo = {
			condition = conditions.lsp_attached,
			update = { "LspAttach", "LspDetach" },
			provider = function()
				local names = {}
				for _, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
					table.insert(names, server.name)
				end

				for _, formatter in pairs(fmt.list_formatters_for_buffer(0)) do
					table.insert(names, formatter)
				end

				return "[ " .. table.concat(names, " ") .. " ]"
			end,
		}

		vim.opt.showcmdloc = "statusline"
		local ShowCmd = {
			condition = function()
				return vim.o.cmdheight == 0
			end,
			provider = "%S",
		}

		local tabname = {
			provider = function(self)
				local name = vim.fn.fnamemodify(self.name, ":t")
				if name == "" then
					name = "(unnamed)"
				end

				if self.is_active then
					name = "[ " .. name .. " ]"
				else
					name = "  " .. name .. "  "
				end

				return name
			end,
			hl = function(self)
				if self.is_active then
					return { fg = "dragonBlack0", bg = "oldWhite" }
				end

				return { fg = "oldWhite" }
			end,
		}

		local tabblock = {
			init = function(self)
				self.name = vim.api.nvim_buf_get_name(self.bufnr)
			end,
			hl = function(self)
				-- TODO: finish this
			end,
			tabname,
			pad(1),
		}

		local tabs = utils.make_buflist(tabblock)

		local cwd = {
			provider = function()
				local cwd = vim.fn.getcwd()

				-- local head = vim.fn.fnamemodify(cwd, ":h:t") .. "/"
				-- local tail = vim.fn.fnamemodify(cwd, ":t")
				-- local last2 = head .. tail
				--
				-- local chosen = last2
				--
				-- -- 18 is a stupid hardcoded value because my user@host is same len on pc and laptop
				-- -- 10 is based on vibes
				-- if #chosen > 18 then
				-- 	if #tail < 10 then
				-- 		chosen = "..." .. string.sub(chosen, 3)
				-- 	elseif #tail < 18 then
				-- 		chosen = tail
				-- 	end
				-- end
				--
				-- if #chosen > 18 then
				-- 	chosen = "..." .. string.sub(chosen, 3)
				-- else
				-- 	chosen = string.rep(" ", 18 - #chosen) .. chosen
				-- end

				return "[ " .. vim.fn.fnamemodify(cwd, ":~") .. " ]"
			end,
			hl = { fg = "dragonGreen" },
		}

		-- local bigmode = {
		-- 	provider = function(self)
		-- 		local modetext = modes[self.mode:sub(1, 1)]
		--
		-- 		local final = modetext .. " - nvim"
		-- 		return (" "):rep(#"eric@shinji - tmux" - #final) .. final
		-- 	end,
		-- 	hl = { fg = "oldWhite" },
		-- 	update = {
		-- 		"ModeChanged",
		-- 		pattern = "*:*",
		-- 		callback = vim.schedule_wrap(function()
		-- 			vim.cmd("redrawtabline")
		-- 		end),
		-- 	},
		-- }

		local smallmode_tabline = modemeta("tabline", {
			provider = " ",
			hl = function(self)
				return {
					bg = colors[self.mode:sub(1, 1)],
				}
			end,
		})

		local smallmode_statusline = modemeta("status", {
			provider = " ",
			hl = function(self)
				return {
					bg = colors[self.mode:sub(1, 1)],
				}
			end,
		})

		local mini_statusline = {
			condition = function()
				return conditions.buffer_matches({ buftype = { "nofile" } })
			end,
			{
				smallmode_statusline,
				pad(1),
				modeforegroundmeta(function()
					return "NOF"
				end, "status"),
				pad(1),
				{
					provider = function()
						local name = vim.api.nvim_buf_get_name(0)
						name = vim.fn.fnamemodify(name, ":.")
						return "[ " .. name .. " ]"
					end,
					hl = { fg = "dragonGreen" },
				},

				fill,

				smallmode_statusline,
			},
		}

		local full_statusline = {
			condition = function()
				return not conditions.buffer_matches({ buftype = { "nofile" } })
			end,
			{
				smallmode_statusline,
				pad(1),
				mode2,
				pad(1),
				cwd,
				pad(1),
				fileblock,

				fill,

				lspinfo,
				pad(1),
				rulers,
				pad(1),
				smallmode_statusline,
			},
		}

		local statusline = {
			full_statusline,
			mini_statusline,
		}

		local tabline = {
			tabs,
			fill,
		}

		vim.o.showtabline = 2
		opts.tabline = tabline
		opts.statusline = statusline
	end,
}
