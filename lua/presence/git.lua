local M = {}

local cache = {
	project = nil,
	cwd = nil,
	timestamp = nil,
	cache_duration = 30 -- Cache for 30 seconds
}

local function is_cache_valid()
	if not cache.cwd or not cache.project or not cache.timestamp then
		return false
	end
	-- Invalidate if directory changed
	local current_cwd = vim.loop.cwd()
	if current_cwd ~= cache.cwd then
		return false
	end
	-- Invalidate if cache expired
	local current_time = os.time()
	if current_time - cache.timestamp > cache.cache_duration then
		return false
	end
	return true
end

local function update_cache(project_name)
	cache.project = project_name
	cache.cwd = vim.loop.cwd()
	cache.timestamp = os.time()
end

M.get_git_project = function ()
	-- Check cache first
	if is_cache_valid() then
		return cache.project
	end
	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]

	local error = string.find(git_root, "fatal:")
	if git_root == nil or git_root == '' or error ~= nil then
		update_cache(nil)
		return nil
	end

	local project_name = vim.fn.fnamemodify(git_root, ":t")
	update_cache(project_name)
	return project_name
end

M.clear_cache = function()
	cache.project = nil
	cache.cwd = nil
	cache.timestamp = nil
end

M.get_cache_info = function()
	return {
		project = cache.project,
		cwd = cache.cwd,
		timestamp = cache.timestamp,
		age = cache.timestamp and (os.time() - cache.timestamp) or nil
	}
end

return M
