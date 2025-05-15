local get_bufs = function()
  return vim.tbl_filter(
    function(bufnr) return vim.api.nvim_get_option_value("buflisted", { buf = bufnr }) end,
    vim.api.nvim_list_bufs()
  )
end

local bufs_cache = {}

vim.api.nvim_create_autocmd({ "VimEnter", "UiEnter", "BufAdd", "BufDelete" }, {
  callback = function()
    vim.schedule(function()
      local buffers = get_bufs()

      for i, v in ipairs(buffers) do
        bufs_cache[i] = v
      end
      for i = #buffers + 1, #bufs_cache do
        bufs_cache[i] = nil
      end
    end)
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  callback = function() vim.wo.winbar = require("heirline").eval_winbar() end,
})

return {
  "rebelot/heirline.nvim",
  lazy = false,
  opts = function(_, opts)
    local status = require "astroui.status"
    local chair = require "utils.chairui"
    local git = require "utils.git"
    local hlu = require "heirline.utils"

    vim.api.nvim_create_autocmd({ "VimEnter", "BufWritePost" }, {
      callback = git.update,
    })

    local cols = {
      tabs = {
        bg = "tabline_bg",
      },
      mainbar = {
        bg = "bg",
      },
    }

    local buffers = hlu.make_buflist(
      chair.FileTab,
      { provider = "<x" },
      { provider = "x>" },
      function() return bufs_cache end,
      false
    )

    local tabs = {
      hl = { bg = cols.tabs.bg },
      chair.filename { hl = function() return { bg = cols.tabs.bg, fg = "fg" } end },
      status.component.builder { provider = "", padding = { left = 2 } },
      buffers,
      status.component.fill(),
    }

    local crumbs = {
      hl = { bg = "bg" },
      status.component.breadcrumbs { separator = " \\ ", icon = { enabled = false } },
      status.component.fill(),
      status.component.diagnostics(),
      status.component.lsp(),
    }

    local mainbar = { -- statusline
      hl = { fg = "fg", bg = cols.mainbar.bg },
      status.component.builder { provider = " ", hl = status.hl.mode },
      chair.mode { cutoff = 3, pad = { left = 1, right = 1 }, color_mode = "invert", hl = { bg = cols.mainbar.bg } },
      chair.file_info { pad = { left = 1, right = 1 }, hl = function() return { bg = cols.mainbar.bg, fg = "fg" } end },
      chair.git { hl = { bg = cols.mainbar.bg } },
      status.component.fill(),
      status.component.virtual_env(),
      status.component.builder {
        provider = status.provider.ruler(),
        hl = { bg = cols.mainbar.bg },
      },
    }

    opts.tabline = tabs
    opts.winbar = mainbar
    opts.statusline = crumbs
  end,
}
