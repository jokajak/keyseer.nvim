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

function M.normal(keystr)
  -- Normal key strings back to keycaps
  local keycap_mapping = {
    ["<C>"] = "<CTRL>",
    ["<S>"] = "<SHIFT>",
  }
  return keycap_mapping[keystr] or keystr
end

function M.center(str, width, shift_left)
  local total_padding = width - vim.fn.strwidth(str)
  local small_pad = math.floor(total_padding / 2)
  local big_pad = math.ceil(total_padding / 2)
  if shift_left then
    return string.rep(" ", small_pad) .. str .. string.rep(" ", big_pad), small_pad, big_pad
  else
    return string.rep(" ", big_pad) .. str .. string.rep(" ", small_pad), big_pad, small_pad
  end
end

return M
