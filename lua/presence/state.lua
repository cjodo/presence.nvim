local git = require("presence.git")

local M = {}

local last_state = nil

local function state_hash(state)
  return string.format("%s|%s|%s|%s|%s",
    state.file or "",
    state.filetype or "",
    state.project or "",
    state.cwd or "",
    state.mode or ""
  )
end

function M.collect()
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)

  local current_state = {
    file = name ~= "" and vim.fn.fnamemodify(name, ":t") or nil,
    filetype = vim.bo.filetype,
		project = git.get_git_project(),
    cwd = vim.loop.cwd(),
    mode = vim.fn.mode(),
  }

  local current_hash = state_hash(current_state)
  local last_hash = last_state and state_hash(last_state)
  
  if current_hash == last_hash then
    return nil, false
  end
  
  last_state = current_state
  return current_state, true
end

function M.get_last_state()
  return last_state
end

function M.reset_state()
  last_state = nil
end

return M
