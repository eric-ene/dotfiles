return {
	"rebelot/kanagawa.nvim",
	name = "kanagawa",
	lazy = false,
	opts = function(_, opts)
		opts.theme = "dragon"
		opts.overrides = function(colors)
			return {
				BlinkCmpMenu = { bg = colors.palette.dragonBlack3 },
				BlinkCmpLabelDetail = { bg = colors.palette.dragonBlack3 },
				BlinkCmpMenuSelection = { bg = colors.palette.waveBlue1 },
			}
		end
	end,
}
