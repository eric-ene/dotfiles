local M = {
  branch = "branch",
  staged_diff = "s",
  total_diff = "t",
}

local function set_default()
  M.branch = "[no git]"
  M.staged_diff = "-"
  M.total_diff = "-"
end

function M.update()
  local handle = io.popen "sh -c 'git status 2&> /dev/null && echo 1 || { echo 0; }'"
  if handle == nil then
    set_default()
    return
  end

  local git_status_present = handle:read "*n" or 0
  handle:close()

  if git_status_present == 0 then
    set_default()
    return
  end

  handle = io.popen "sh -c 'git branch --show-current'"
  if handle == nil then
    set_default()
    return
  end

  M.branch = handle:read "*l"
  handle:close()

  handle = io.popen "sh -c 'git diff --numstat --staged | wc -l'"
  if handle == nil then
    set_default()
    return
  end

  M.staged_diff = handle:read "*n"
  handle:close()

  handle = io.popen "sh -c 'git diff --numstat | wc -l'"
  if handle == nil then
    set_default()
    return
  end

  M.total_diff = handle:read "*n" + M.staged_diff
  handle:close()
end

return M
