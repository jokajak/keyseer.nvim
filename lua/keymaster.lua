local layouts = require("keymaster.layouts")

local M = {}

local function with_defaults(options)
  return {
    name = options.name or "John Doe",
    layout = options.layout or "qwerty",
  }
end

-- This function is supposed to be called explicitly by users to configure this
-- plugin
function M.setup(options)
  options = options or {}
  M.options = with_defaults(options)
end

function M.is_configured()
  return M.options ~= nil
end

M.options = nil

-- From https://dev.to/2nit/how-to-write-neovim-plugins-in-lua-5cca

local api = vim.api
local buf, win

local function open_window(columns, lines)
  buf = api.nvim_create_buf(false, true) -- create new emtpy buffer

  api.nvim_buf_set_option(buf, "bufhidden", "wipe")

  -- get dimensions
  local width = api.nvim_get_option("columns")
  local height = api.nvim_get_option("lines")

  -- calculate our floating window size
  local win_height = lines + 4
  local win_width = columns + 4

  -- and its starting position
  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width - win_width) / 2)

  -- set some options
  local opts = {
    style = "minimal",
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col,
  }

  -- and finally create it with buffer attached
  win = api.nvim_open_win(buf, true, opts)
end

local function center(str)
  local width = api.nvim_win_get_width(0)
  local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
  return string.rep(" ", shift) .. str
end

local function update_view(lines)
  -- Is nice to prevent user from editing interface, so
  -- we should enabled it before updating view and disabled after it.
  api.nvim_buf_set_option(buf, "modifiable", true)

  -- add a little indentation
  for i = 1, #lines do
    lines[i] = "  " .. lines[i]
  end

  api.nvim_buf_set_lines(buf, 0, -1, false, {
    center("Keymaster"),
    "",
  })
  api.nvim_buf_set_lines(buf, 2, -1, false, lines)
end

local function close_window()
  api.nvim_win_close(win, true)
end

local function move_cursor()
  local new_pos = math.max(3, api.nvim_win_get_cursor(win)[1] - 1)
  api.nvim_win_set_cursor(win, { new_pos, 0 })
end
-- Display starts on line 3, prevent going above that

function M.display()
  if not M.is_configured() then
    return
  end

  local keycap_keys = layouts.layouts[M.options.layout]

  local layout = layouts.render(keycap_keys)
  open_window(layout.row_length, #layout.layout)
  update_view(layout.layout)
  api.nvim_win_set_cursor(win, { 3, 0 })
end

-- Expose functions
M.open_window = open_window
M.close_window = close_window
M.move_cursor = move_cursor
return M
