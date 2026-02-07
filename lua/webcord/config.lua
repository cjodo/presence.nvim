local M = {}

M.defaults = {
  endpoint = "http://localhost:3000/presence",
  user = "anonymous",
  token = nil,
  heartbeat_interval = 30,
  enabled = true,
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

return M
