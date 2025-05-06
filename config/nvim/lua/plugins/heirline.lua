return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    local status = require "astroui.status"
    opts.statusline = { -- statusline
      hl = { fg = "fg", bg = "bg" },
      status.component.mode {
        mode_text = { padding = { left = 1, right = 1 } },
      }, -- add the mode text
      status.component.git_branch(),
      status.component.git_diff(),
      status.component.lsp(),
      status.component.diagnostics(),
      status.component.fill(),
      status.component.file_info(),
      status.component.virtual_env(),
      status.component.nav(),
      -- remove the 2nd mode indicator on the right
    }
  end,
}
