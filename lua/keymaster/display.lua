local config = require("keymaster.config")
local Layout = require("keymaster.layout")
local Util = require("keymaster.util")

local M = {}

M.mode = "n"
M.buf = nil
M.win = nil

function M.is_valid()
  return M.buf
    and M.win
    and vim.api.nvim_buf_is_valid(M.buf)
    and vim.api.nvim_buf_is_loaded(M.buf)
    and vim.api.nvim_win_is_valid(M.win)
end

function M.show()
  if M.is_valid() then
    return
  end

  -- get current dimensions
  local width = vim.o.columns
  local height = vim.o.lines

  -- configure the size
  local win_height = config.options.window.rows
  win_height = win_height + config.options.window.margin[1]
  win_height = win_height + config.options.window.margin[3]
  local win_width = config.options.window.columns
  win_width = win_width + config.options.window.margin[2]
  win_width = win_width + config.options.window.margin[4]

  -- calculate starting position
  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width - win_width) / 2)

  local opts = {
    relative = "editor",
    style = "minimal",
    width = win_width,
    height = win_height,
    focusable = false,
    row = row,
    col = col,
    border = config.options.window.border,
    noautocmd = true,
  }

  M.buf = vim.api.nvim_create_buf(false, true) -- create new empty buffer

  M.win = vim.api.nvim_open_win(M.buf, true, opts)

  vim.api.nvim_buf_set_option(M.buf, "filetype", "keymaster")
  vim.api.nvim_buf_set_option(M.buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(M.buf, "bufhidden", "wipe")
  --[[ vim.api.nvim_buf_set_name(M.buf, "[keymaster]") ]]

  local winhl = "NormalFloat:KeymasterFloat"
  if vim.fn.hlexists("FloatBorder") == 1 then
    winhl = winhl .. ",FloatBorder:KeymasterBorder"
  end
  vim.api.nvim_win_set_option(M.win, "winhighlight", winhl)
  vim.api.nvim_win_set_option(M.win, "foldmethod", "manual")
  vim.api.nvim_win_set_option(M.win, "winblend", config.options.window.winblend)
end

function M.on_close()
  M.hide()
end

function M.hide()
  vim.api.nvim_echo({ { "" } }, false, {})
  if M.buf and vim.api.nvim_buf_is_valid(M.buf) then
    vim.api.nvim_buf_delete(M.buf, { force = true })
    M.buf = nil
  end
  if M.win and vim.api.nvim_win_is_valid(M.win) then
    vim.api.nvim_win_close(M.win, true)
    M.win = nil
  end
  vim.cmd("redraw")
end

function M.open(opts)
  opts = opts or {}
  M.mode = opts.mode or Util.get_mode()

  local buf = vim.api.nvim_get_current_buf()

  if M.is_enabled(buf) then
    if not M.is_valid() then
      M.show()
    end

    local layout = Layout:new(opts)
    M.render(layout:layout())
  end
  vim.cmd([[redraw]])
end

function M.is_enabled(buf)
  local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
  for _, bt in ipairs(config.options.disable.buftypes) do
    if bt == buftype then
      return false
    end
  end

  local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
  for _, bt in ipairs(config.options.disable.filetypes) do
    if bt == filetype then
      return false
    end
  end

  return true
end

--- Utility to make the initial display buffer header
local function make_header(disp, width)
  width = width or vim.api.nvim_win_get_width(0)
  local pad_width = math.floor((width - string.len(config.options.window.title)) / 2.0)
  vim.api.nvim_buf_set_lines(disp.buf, 0, 1, true, {
    string.rep(" ", pad_width) .. config.options.window.title,
    " " .. string.rep(config.options.window.header_sym, width - 2),
  })
end

---@param text Text
function M.render(text)
  vim.api.nvim_buf_set_option(M.buf, "modifiable", true)
  local width = text.width

  local start_row = 0
  if config.options.window.show_title then
    make_header(M, width)
    start_row = config.options.window.header_lines
  end
  vim.api.nvim_buf_set_lines(M.buf, start_row, -1, false, text.lines)

  local height = #text.lines + start_row
  vim.api.nvim_win_set_height(M.win, height)
  vim.api.nvim_win_set_width(M.win, width)
  if vim.api.nvim_buf_is_valid(M.buf) then
    vim.api.nvim_buf_clear_namespace(M.buf, config.namespace, 0, -1)
  end
  vim.api.nvim_buf_set_option(M.buf, "modifiable", false)
end

return M
