local config = require("presence.config")
local state = require("presence.state")
local api = require("presence.api")
local heartbeat = require("presence.scheduler")
local Status = require("presence.status")

local M = {}

local neovim_status = nil

local function send()
  if not config.options.enabled or not neovim_status then return end

  local presence = neovim_status:create_presence(state.collect())
  api.post(config.options, presence)
end

function M.setup(opts)
  config.setup(opts)
  neovim_status = Status.new(config.options)

  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      neovim_status:set_online()
      send()
      heartbeat.start(config.options.heartbeat_interval, function()
        send()
      end)
    end,
  })

  vim.api.nvim_create_autocmd({
    "BufEnter",
    "BufWritePost",
    "ModeChanged",
  }, {
    callback = function()
      if neovim_status:is_offline() then
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

-- Expose status methods for external access
function M.get_status()
  return neovim_status and neovim_status:get_status() or { status = "offline" }
end

function M.is_online()
  return neovim_status and neovim_status:is_online() or false
end

return M
