local M = {}

M.get_git_project = function ()
	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]

	local error = string.find(git_root, "fatal:")
	if git_root == nil or git_root == '' or error ~= nil then
		return nil
	end

	local project_name = vim.fn.fnamemodify(git_root, ":t")
	return project_name
end

M.get_git_project()

return M
