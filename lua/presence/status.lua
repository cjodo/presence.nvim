local M = {}

local NeovimStatus = {}
NeovimStatus.__index = NeovimStatus

function NeovimStatus:new(config)
  local obj = {
    config = config,
    current_status = "offline",
    last_update = nil,
    session_id = vim.fn.sha256(
      tostring(vim.loop.hrtime()) .. tostring(vim.fn.getpid())
    ),
  }
  setmetatable(obj, NeovimStatus)
  return obj
end

function NeovimStatus:is_online()
  return self.current_status == "online"
end

function NeovimStatus:is_offline()
  return self.current_status == "offline"
end

function NeovimStatus:set_online()
  self.current_status = "online"
  self.last_update = os.time()
end

function NeovimStatus:set_offline()
  self.current_status = "offline"
  self.last_update = os.time()
end

function NeovimStatus:get_status()
  return {
    status = self.current_status,
    updated_at = self.last_update,
    session = self.session_id,
    user = self.config.user,
  }
end

function NeovimStatus:create_presence(state_data)
  return vim.tbl_extend("force", self:get_status(), state_data or {})
end

function M.new(config)
  return NeovimStatus:new(config)
end

return M
