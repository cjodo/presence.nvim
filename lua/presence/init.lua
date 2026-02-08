local config = require("presence.config")
local state = require("presence.state")
local api = require("presence.api")
local heartbeat = require("presence.scheduler")
local Status = require("presence.status")

local M = {}

local live = true

local neovim_status = nil
local event_autocmds = nil

local function send()
	if not live then
		return
	end

	if not config.options.enabled or not neovim_status then return end

	local presence = neovim_status:create_presence(state.collect())
	api.post(config.options, presence)
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

function M.setup(opts)
	config.setup(opts)
	neovim_status = Status.new(config.options)

	if config.options.autostart then
		vim.api.nvim_create_autocmd("VimEnter", {
			callback = function()
				neovim_status:set_online()
				send()
				heartbeat.start(config.options.heartbeat_interval, function()
					send()
				end)
				create_event_autocmds()
			end,
		})
	end
end

-- Expose status methods for external access
function M.get_status()
	return neovim_status and neovim_status:get_status() or { status = "offline" }
end

function M.is_online()
	return neovim_status and neovim_status:is_online() or false
end

function M.stop()
	live = false
	heartbeat.stop()
	if neovim_status then
		neovim_status:set_offline()
		send()
	end
	clear_event_autocmds()
end

function M.start()
	if not neovim_status then return end
	live = true
	neovim_status:set_online()
	send()
	heartbeat.start(config.options.heartbeat_interval, function()
		send()
	end)
	create_event_autocmds()
end

return M
