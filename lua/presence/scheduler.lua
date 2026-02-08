local M = {}
local timer

function M.start(interval, fn)
  timer = vim.loop.new_timer()
  timer:start(
    interval * 1000,
    interval * 1000,
    vim.schedule_wrap(fn)
  )
end

function M.stop()
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end
end

return M

