local endpoints = require("presence.endpoints")

local M = {}

function M.post(config, payload)
	local body = vim.json.encode(payload)
	local healthy_endpoints = endpoints.get_healthy_endpoints()

	if #healthy_endpoints == 0 then
		return
	end

	for _, endpoint in ipairs(healthy_endpoints) do
		local cmd = {
			"curl",
			"-s",
			"-X", "POST",
			"-H", "Content-Type: application/json",
			"-d", body,
			endpoint,
		}

		if config.token then
			table.insert(cmd, 5, "-H")
			table.insert(cmd, 6, "Authorization: Bearer " .. config.token)
		end

		vim.system(cmd, { detach = true }, function(obj)
			if obj.code == 0 then
				endpoints.mark_success(endpoint)
			else
				endpoints.mark_failure(endpoint)
			end
		end)
	end
end

return M
