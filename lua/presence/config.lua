local M = {}

M.defaults = {
	autostart = true,
	endpoints = { "http://localhost:3000/presence" },
	user = "anonymous",
	token = nil,
	heartbeat_interval = 5,
	enabled = true,
	endpoint_retry_interval = 30,
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

return M
