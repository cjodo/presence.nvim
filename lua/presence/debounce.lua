local M = {}

local Debounce = {}
Debounce.__index = Debounce

function Debounce:new(delay, fn)
  local obj = {
    delay = delay,
    fn = fn,
    timer = nil,
    pending = false
  }
  setmetatable(obj, Debounce)
  return obj
end

function Debounce:call(...)
  local args = {...}
  if self.timer then
    self.timer:stop()
    self.timer:close()
    self.timer = nil
  end

  self.timer = vim.loop.new_timer()
  self.timer:start(self.delay, 0, vim.schedule_wrap(function()
    local unpack = unpack or table.unpack
    self.fn(unpack(args))
    self.timer = nil
  end))
end

function Debounce:flush()
  if self.timer then
    self.timer:stop()
    self.timer:close()
    self.timer:close()
    self.timer = nil
  end
end

function M.debounce(delay, fn)
  return Debounce:new(delay, fn)
end

return M
