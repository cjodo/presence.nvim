local config = require("webcord.config")
local state = require("webcord.state")
local api = require("webcord.api")
local heartbeat = require("webcord.scheduler")

local M = {}

local session_id = vim.fn.sha256(
  tostring(vim.loop.hrtime()) .. tostring(vim.fn.getpid())
)

local function send(status)
  if not config.options.enabled then return end

  api.post(config.options, vim.tbl_extend("force", {
    user = config.options.user,
    session = session_id,
    status = status,
    updated_at = os.time(),
		--body
  }, state.collect()))
end

function M.setup(opts)
  config.setup(opts)

  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      send("online")
      heartbeat.start(config.options.heartbeat_interval, function()
        send("online")
      end)
    end,
  })

  vim.api.nvim_create_autocmd({
    "BufEnter",
    "BufWritePost",
    "ModeChanged",
  }, {
    callback = function()
      send("online")
    end,
  })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      heartbeat.stop()
      send("offline")
    end,
  })
end

return M
