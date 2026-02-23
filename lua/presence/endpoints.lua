local M = {}

local endpoint_status = {}
local config = nil
local retry_timer = nil
local retry_interval = 30

local function create_endpoint_status(endpoint)
	return {
		endpoint = endpoint,
		healthy = true,
		failures = 0,
		last_failure = nil,
		last_success = nil,
	}
end

local function init_endpoints(endpoints)
	for _, endpoint in ipairs(endpoints) do
		if not endpoint_status[endpoint] then
			endpoint_status[endpoint] = create_endpoint_status(endpoint)
		end
	end
	for endpoint, _ in pairs(endpoint_status) do
		local found = false
		for _, ep in ipairs(endpoints) do
			if ep == endpoint then
				found = true
				break
			end
		end
		if not found then
			endpoint_status[endpoint] = nil
		end
	end
end

function M.setup(opts)
	config = opts
	if opts.endpoints then
		init_endpoints(opts.endpoints)
	end
	retry_interval = opts.endpoint_retry_interval or 30
end

function M.get_healthy_endpoints()
	local healthy = {}
	for endpoint, status in pairs(endpoint_status) do
		if status.healthy then
			table.insert(healthy, endpoint)
		end
	end
	return healthy
end

function M.mark_success(endpoint)
	if endpoint_status[endpoint] then
		endpoint_status[endpoint].healthy = true
		endpoint_status[endpoint].failures = 0
		endpoint_status[endpoint].last_success = os.time()
	end
end

function M.mark_failure(endpoint)
	if endpoint_status[endpoint] then
		endpoint_status[endpoint].healthy = false
		endpoint_status[endpoint].failures = endpoint_status[endpoint].failures + 1
		endpoint_status[endpoint].last_failure = os.time()
	end
end

function M.is_healthy(endpoint)
	return endpoint_status[endpoint] and endpoint_status[endpoint].healthy
end

function M.get_status()
	local status = {}
	for endpoint, s in pairs(endpoint_status) do
		status[endpoint] = {
			healthy = s.healthy,
			failures = s.failures,
			last_failure = s.last_failure,
			last_success = s.last_success,
		}
	end
	return status
end

function M.has_healthy_endpoints()
	for _, status in pairs(endpoint_status) do
		if status.healthy then
			return true
		end
	end
	return false
end

function M.reset(endpoint)
	if endpoint then
		if endpoint_status[endpoint] then
			endpoint_status[endpoint] = create_endpoint_status(endpoint)
		end
	else
		for ep, _ in pairs(endpoint_status) do
			endpoint_status[ep] = create_endpoint_status(ep)
		end
	end
end

return M
