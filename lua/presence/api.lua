local M = {}

--TODO: Replace with http when more built out
function M.post(config, payload)
  local body = vim.json.encode(payload)

	for _, endpoint in ipairs(config.endpoints) do

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

		vim.system(cmd, { detach = true })
	end


end

return M

