local tmux_suffix = " - tmux"
local user = os.getenv "USER"
local host = "kaworu"
local user_at_host = user .. "@" .. host .. tmux_suffix

local maxlen = string.len(user_at_host)

local providers = {}
local M = {}
local git = require "utils.git"

function providers.extend_tbl(default, new) return vim.tbl_deep_extend("force", default, new) end

function providers.padclip(p_str, p_maxlen)
  local strlen = string.len(p_str)
  local rem = p_maxlen - strlen

  if rem >= 1 then return string.rep(" ", rem) .. p_str end
  return "..." .. string.sub(p_str, strlen - p_maxlen + 4, strlen)
end

-- returns file info to be put in the tabline. needs to be aligned to tmux title
function providers.fileinfo()
  local retval = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")

  retval = providers.padclip(retval, maxlen - #" - nvim " + 1)
  return retval .. " - nvim "
end

function providers.filetype(padding)
  local ftype_fn = status.provider.filetype()
  local ftype = ftype_fn()

  return string.rep(" ", padding.left) .. ftype .. string.rep(" ", padding.right)
end

function providers.mode(lower, p_cutoff, padding)
  local mode_fn = status.provider.mode_text()
  local mode = mode_fn()

  if lower then mode = string.lower(mode) end
  local cutoff

  if p_cutoff then
    cutoff = p_cutoff
  else
    cutoff = 6
  end

  mode = string.sub(mode, 0, cutoff)

  return string.rep(" ", padding.left) .. mode .. string.rep(" ", padding.right)
end

function providers.git(padding)
  -- local handle = io.popen "sh -c 'git status 2&> /dev/null && echo 1 || { echo 0; }'"
  -- if handle == nil then return "" end
  --
  -- local git_status_present = handle:read "*n" or 0
  -- handle:close()
  --
  -- if git_status_present == 0 then return "" end
  --
  -- handle = io.popen "sh -c 'git branch --show-current'"
  -- if handle == nil then return "" end
  --
  -- local final = handle:read "*l"
  -- handle:close()

  return git.branch .. string.rep(" ", padding)
end

function providers.diff_staged(padding)
  -- local handle = io.popen "sh -c 'git diff --numstat --staged | wc -l'"
  -- if handle == nil then return "" end
  --
  -- local diff_staged = handle:read "*n"
  -- handle:close()

  return git.staged_diff .. string.rep(" ", padding)
end

function providers.diff_total(padding)
  -- local handle = io.popen "sh -c 'git diff --numstat --staged | wc -l'"
  -- if handle == nil then return "" end
  --
  -- local diff = handle:read "*n"
  -- handle:close()
  --
  -- handle = io.popen "sh -c 'git diff --numstat | wc -l'"
  -- if handle == nil then return "" end
  --
  -- diff = handle:read "*n" + diff
  -- handle:close()

  return git.total_diff .. string.rep(" ", padding)
end

function M.filename(p_opts)
  local opts = providers.extend_tbl({ provider = providers.fileinfo }, p_opts)
  return status.component.builder(opts)
end

function M.file_info(p_opts)
  local opts = providers.extend_tbl(
    { provider = function() return providers.filetype(p_opts.pad or { left = 1, right = 1 }) end },
    p_opts
  )
  return status.component.builder(opts)
end

function M.mode(p_opts)
  local lower = p_opts.lower or false
  local cutoff = p_opts.cutoff or false
  local inv = p_opts.color_mode or "none"
  local pad = p_opts.pad or { left = 0, right = 0 }

  local lut = {
    ["none"] = p_opts.hl,
    ["invert"] = function() return { bg = "tabline_bg", fg = status.hl.mode_bg() } end,
    ["default"] = function() return { fg = "bg", bg = status.hl.mode_bg() } end,
  }

  local choice = lut[inv]

  local opts =
    providers.extend_tbl({ provider = function() return providers.mode(lower, cutoff, pad) end, hl = choice }, p_opts)
  return status.component.builder(opts)
end

function M.git(p_opts)
  p_opts = p_opts or {}

  local braces = { "[ ", " ]" }

  local pad = p_opts.pad or { left = 1, right = 1 }

  local i_name = 1
  local i_pad = 2
  local i_fg = 3

  
end

function M.gd_debug(p_opts)
  local msg = "godot info: "

  if is_server_running then msg = msg .. " server " end
  if is_godot_project then msg = msg .. "godot " end

  return s_component.builder { provider = msg }
end

local Bufnr = {
  init = function(self)
    if not self._show_picker then return end

    if not vim.tbl_get(self._picker_labels, self.label) then
      local bufname = vim.fn.fnamemodify(self.filename, ":t")
      local label = bufname:sub(1, 1)
      local i = 2
      while label ~= " " and self._picker_labels[label] do
        if i > #bufname then break end
        label = bufname:sub(i, i)
        i = i + 1
      end
      self._picker_labels[label] = self.bufnr
      self.label = label
    end
  end,
  provider = function(self) return (not self._show_picker and tostring(self.bufnr) or tostring(self.label)) .. " " end,
}

local FileName = {
  provider = function(self)
    local filename = self.filename
    filename = filename == "" and "_unitled" or vim.fn.fnamemodify(filename, ":t")
    return filename
  end,
}

local FileFlags = {
  {
    condition = function(self) return vim.api.nvim_get_option_value("modified", { buf = self.bufnr }) end,
    provider = "*",
  },
  {
    condition = function(self)
      return not vim.api.nvim_get_option_value("modifiable", { buf = self.bufnr })
        or vim.api.nvim_get_option_value("readonly", { buf = self.bufnr })
    end,
    provider = "-",
  },
}

local FileTab = {
  init = function(self) self.filename = vim.api.nvim_buf_get_name(self.bufnr) end,
  hl = function(self)
    return self.is_active and {
      fg = "bg",
      bg = "git_added",
    } or {
      fg = "fg",
      bg = "tabline_bg",
    }
  end,
  {
    { provider = function(self) return self.is_active and "[ " or "  " end },
    Bufnr,
    FileName,
    FileFlags,
    { provider = function(self) return self.is_active and " ]" or "  " end },
  },
}

M.FileTab = FileTab

return M
