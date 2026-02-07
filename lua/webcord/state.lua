local M = {}

function M.collect()
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)

  return {
    file = name ~= "" and vim.fn.fnamemodify(name, ":t") or nil,
    filetype = vim.bo.filetype,
    cwd = vim.loop.cwd(),
    mode = vim.fn.mode(),
  }
end

return M
