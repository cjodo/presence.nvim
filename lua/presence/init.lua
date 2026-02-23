local config = require("presence.config")
local state = require("presence.state")
local api = require("presence.api")
local heartbeat = require("presence.scheduler")
local Status = require("presence.status")
local debounce = require("presence.debounce")
local endpoints = require("presence.endpoints")

local M = {}

local live = true

local neovim_status = nil
local event_autocmds = nil
local debounced_send = nil
local endpoint_retry_timer = nil

local function send_immediately()
	if not live then
		return
	end

	if not config.options.enabled or not neovim_status then return end

	local current_state, has_changed = state.collect()
	if not has_changed then
		return
	end

	local presence = neovim_status:create_presence(current_state)
	api.post(config.options, presence)
end

local function send()
	if not debounced_send then
		debounced_send = debounce.debounce(300, send_immediately)
	end
	debounced_send:call()
end

local function create_event_autocmds()
	if event_autocmds then return end
	event_autocmds = vim.api.nvim_create_autocmd({
		"BufEnter",
		"BufWritePost",
		"ModeChanged",
	}, {
		callback = function()
			if neovim_status ~= nil and neovim_status:is_offline() then
				neovim_status:set_online()
			end
			send()
		end,
	})

	vim.api.nvim_create_autocmd("BufLeave", {
		callback = function()
			heartbeat.stop()
			neovim_status:set_offline()
			send()
		end,
	})
end

local function clear_event_autocmds()
	if event_autocmds then
		vim.api.nvim_del_autocmd(event_autocmds)
		event_autocmds = nil
	end
end

local function start_endpoint_retry()
	if endpoint_retry_timer then return end
	local interval = config.options.endpoint_retry_interval or 30
	endpoint_retry_timer = vim.loop.new_timer()
	endpoint_retry_timer:start(
		interval * 1000,
		interval * 1000,
		vim.schedule_wrap(function()
			if not live then return end
			if not endpoints.has_healthy_endpoints() then return end
			local current_state, _ = state.collect()
			if current_state then
				local presence = neovim_status:create_presence(current_state)
				api.post(config.options, presence)
			end
		end)
	)
end

local function stop_endpoint_retry()
	if endpoint_retry_timer then
		endpoint_retry_timer:stop()
		endpoint_retry_timer:close()
		endpoint_retry_timer = nil
	end
end

function M.setup(opts)
	config.setup(opts)
	neovim_status = Status.new(config.options)
	endpoints.setup(config.options)

	if config.options.autostart then
		vim.api.nvim_create_autocmd("VimEnter", {
			callback = function()
				neovim_status:set_online()
				send()
				heartbeat.start(config.options.heartbeat_interval, function()
					send()
				end)
				create_event_autocmds()
				start_endpoint_retry()
			end,
		})
	end
end

-- Expose status methods for external access
function M.get_status()
	local status = neovim_status and neovim_status:get_status() or { status = "offline" }
	status.endpoints = endpoints.get_status()
	return status
end

function M.is_online()
	return neovim_status and neovim_status:is_online() or false
end

function M.stop()
	live = false
	heartbeat.stop()
	stop_endpoint_retry()
	if debounced_send then
		debounced_send:flush()
	end
	if neovim_status then
		neovim_status:set_offline()
		send_immediately()
	end
	clear_event_autocmds()
end

function M.start()
	if not neovim_status then return end
	live = true
	state.reset_state()
	neovim_status:set_online()
	send()
	heartbeat.start(config.options.heartbeat_interval, function()
		send()
	end)
	create_event_autocmds()
	start_endpoint_retry()
end

return M
