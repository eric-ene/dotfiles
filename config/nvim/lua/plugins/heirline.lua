local pad = function(num)
  return {  
    provider = function()
      return string.rep(" ", num)
    end,
  }
end

return {
	"rebelot/heirline.nvim",
	lazy = false,
	dependencies = {
    "kanagawa"
  },
   
	opts = function(_, opts)
	  vim.cmd("colorscheme kanagawa")
    vim.cmd("set noshowmode")
    local colors = require("kanagawa.colors").setup().palette
 	  require("heirline").load_colors(colors)

    local utils = require("heirline.utils")
    local conditions = require("heirline.conditions")
				
				local modes = {
          n = "   nor ",
					i = " 󰏫  ins ",
					v = " 󰇀  vis ",
					c = "   cmd ",
				}
				local colors = {
					n = "oldWhite",
					i = "dragonGreen",
					v = "dragonViolet",
					c = "dragonRed",
				}

    local mode = {
	
			init = function(self)
				self.mode = vim.fn.mode(1)
			end,

			provider = function(self)
				return modes[self.mode:sub(1, 1)]
			end,

			hl = function(self)
				return { bg = colors[self.mode:sub(1, 1)], fg = "dragonBlack0" }
			end,

			update = {
				"ModeChanged",
				pattern = "*:*",
				callback = vim.schedule_wrap(function()
					vim.cmd("redrawstatus")
				end),
	
			}
		}

    local filenameinfo = {
      provider = function(self)
        local filepath = vim.fn.fnamemodify(self.filename, ":.")
        if filepath == "" then return "[unnamed file]" end
        
        if not conditions.width_percent_below(#filepath, 0.25) then
          filepath = vim.fn.pathshorten(filepath)
        end

        return filepath
      end,
    }

    local fileflags = {
      {condition = function()
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
      hl = { fg = "dragonRed" }
    }
    }

    local filetype = {
      provider = function()
        return " <" .. vim.bo.filetype .. "> "
      end,
      hl = function() return {
        fg = "dragonBlack0",
        bg = colors[vim.fn.mode(1):sub(1, 1)]
      } end,
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

    }
    
    vim.opt.showcmdloc = 'statusline'
local ShowCmd = {
    condition = function()
        return vim.o.cmdheight == 0
    end,
    provider = "%S",
} 

		local statusline = {
			mode,
      pad(1),
      ShowCmd,
      fill,
      fileblock,
		}
		
		opts.statusline = statusline
	end
}
