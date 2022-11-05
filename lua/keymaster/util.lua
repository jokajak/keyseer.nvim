local M = {}

function M.t(str)
  -- https://github.com/neovim/neovim/issues/17369
  local ret = vim.api.nvim_replace_termcodes(str, false, true, true):gsub("\128\254X", "\128")
  return ret
end

function M.get_mode()
  local mode = vim.api.nvim_get_mode().mode
  mode = mode:gsub(M.t("<C-V>"), "v")
  mode = mode:gsub(M.t("<C-S>"), "s")
  return mode:lower()
end

return M
