local M = {}

-- From https://dev.to/2nit/how-to-write-neovim-plugins-in-lua-5cca

local api = vim.api
local buf, win

local function open_window()
  buf = api.nvim_create_buf(false, true) -- create new emtpy buffer

  api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

  -- get dimensions
  local width = api.nvim_get_option("columns")
  local height = api.nvim_get_option("lines")

  -- calculate our floating window size
  local win_height = math.ceil(height * 0.8 - 4)  -- 80% high minus 4 lines
  local win_width = math.ceil(width * 0.8) -- 80% wide

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
    col = col
  }

  -- and finally create it with buffer attached
  win = api.nvim_open_win(buf, true, opts)
end

local position = 0
local charset = {
  -- [ up down left right ] = char
  --      s : single
  [" s s"] = "┌",
  ["ss  "] = "│",
  ["sss "] = "┤",
  [" ss "] = "┐",
  ["s  s"] = "└",
  ["s ss"] = "┴",
  [" sss"] = "┬",
  ["ss s"] = "├",
  ["  ss"] = "─",
  ["ssss"] = "┼",
  ["s s "] = "┘",
  ["topleft"] = "┌",
}

local function center(str)
  local width = api.nvim_win_get_width(0)
  local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
  return string.rep(' ', shift) .. str
end

local function render()
end

local function update_view()
  -- Is nice to prevent user from editing interface, so
  -- we should enabled it before updating view and disabled after it.
  api.nvim_buf_set_option(buf, 'modifiable', true)

  api.nvim_buf_set_lines(buf, 0, -1, false, {
      center('What have i done?'),
      ''
    })
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

function M.display()
  return "Hello " .. name
end
function M.render(layout_keys)
  -- layout_keys is a table of key fronts where:
  -- the left hand side (lhs) is the qwerty keyboard label
  -- the right hand side (rhs) is the label on the key
  -- the order from left to right, top to bottom

  -- top row: 14 keys
  -- second row: 14 keys
  -- third row: 13 keys
  -- bottom row: 12 keys

  -- render the first line
  local lines = {

    "┌─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┐",
    "│%s│%s│%s│%s│%s│%s│%s│%s│%s│%s│%s│%s│%s│%s│",
    "├─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┤",
    "│%s│%s│%s│%s│%s│%s│%s│%s│%s│%s│%s│%s│%s│%s│",
    "├─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┤",
    "│%s│%s│%s│%s│%s│%s│%s│%s│%s│%s│%s│%s│%s│%s│",
    "├─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┤",
    "│%s│%s│%s│%s│%s│%s│%s│%s│%s│%s│%s│%s│%s│%s│",
    "└─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┘",
  }
  update_view()
end

return M
