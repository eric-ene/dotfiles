local paths = { "/", "/../" }
local is_godot_proj = false
local godot_proj_path = ""
local cwd = vim.fn.getcwd()

for _, path in pairs(paths) do
	if vim.uv.fs_stat(cwd .. path .. "project.godot") then
		is_godot_proj = true
		godot_proj_path = cwd .. path
		break
	end
end

local pipe = godot_proj_path .. "nvim-server.pipe"

local is_server_running = vim.uv.fs_stat(pipe)

if is_godot_proj and not is_server_running then
	vim.fn.serverstart(pipe)
end
