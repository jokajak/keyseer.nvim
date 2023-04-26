-- This code is responsible for managing the display
local D = require("keyfinder.util.debug")
local config = require("keyfinder.config")

local if_nil = vim.F.if_nil

---@class Display
---@field mode string The neovim mode for keymappings
---@field window table The window options
---@field title string The title of the display
---@field show_title boolean Whether or not to show the title
---@field show_legend boolean Whether or not to show the legend
---@field private _keyboard Keyboard the keyboard layout
---@field private _keymaps Keymaps The parsed neovim keymaps
--- Display is the main UI that shows to interact with the keyboards
local Display = {}
Display.__index = Display

---Create a new Display
---@param opts table Display options
function Display:new(opts)
  opts = opts or {}

  if vim.fn.win_gettype() == "command" then
    error("Can't open keyfinder from command-line window. See E11")
  end

  local obj = setmetatable({
    mode = if_nil(opts.mode, config.options.initial_mode),

    window = {
      winblend = if_nil(
        opts.winblend,
        type(opts.window) == "table" and opts.window.winblend or config.options.window.winblend
      ),
      border = if_nil(
        opts.border,
        type(opts.window) == "table" and opts.window.border or config.options.window.border
      ),
    },
    show_title = if_nil(opts.show_title, config.options.window.show_title),
    show_legend = if_nil(opts.show_legend, config.options.window.show_legend),
    title = if_nil(opts.title, config.options.window.title),
  }, self)
  local keyboard_opts = if_nil(opts.keyboard, config.options.keyboard)
  local keyboard = keyboard_opts.layout

  if type(keyboard) == "string" then
    self._keyboard = require("keyfinder.keyboard." .. keyboard):new(keyboard_opts)
  else
    self._keyboard = keyboard:new(keyboard_opts)
  end
  return obj
end

---Utility to make the initial display buffer header
---@param width number The width for the header
---@return string[] The lines in the header
local function get_header_lines(width)
  local lines = {}
  width = width or vim.api.nvim_win_get_width(0)
  local pad_width =
    math.floor((width - vim.fn.strdisplaywidth(config.options.window.title, 0)) / 2.0)
  table.insert(lines, string.rep(" ", pad_width) .. config.options.window.title)
  -- add the seperator row with a space at the beginning and end
  table.insert(lines, string.rep(config.options.window.header_sym, width))
  return lines
end

---Utility to make the legend at the bottom
local function get_legend_lines(width)
  width = width or vim.api.nvim_win_get_width(0)
  local key_legend_text = "<bs> go up one level <esc> close"
  local pad_width = math.floor((width - vim.fn.strdisplaywidth(key_legend_text, 0)) / 2.0)
  local lines = {
    "Legend:",
    " Has a mapping",
    " Prefix for multiple mappings",
    string.rep(" ", pad_width) .. key_legend_text,
  }
  return lines
end

---Create a vim window
--- Inspired by plenary.nvim
---@param lines string[] The lines to display in the window
---@param vim_options table The options for the window
---@return number win_id The id of the window that gets created
local function _create_window(lines, vim_options)
  vim_options = vim.deepcopy(vim_options)
  -- get the ui reference
  local ui = vim.api.nvim_list_uis()[1]
  local width = 0
  local height = vim.fn.len(lines)

  for _, v in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(v, 0))
  end

  local win_opts = {
    relative = "editor",
    style = "minimal",
    focusable = false,
    border = vim_options.window.border,
    noautocmd = true,
    height = height,
    width = width,
    row = math.ceil((ui.height - height) / 2 - 1),
    col = math.ceil((ui.width - width) / 2),
  }

  if (ui.width < width) or (ui.height < win_opts.height) then
    print("Window too small")
  end

  -- create new buffer that is listed=false scratch=true
  local bufnr = vim.api.nvim_create_buf(false, true)
  -- don't show the buffer in lists and delete it when it is hidden
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
  -- buffer is not backed by a file
  vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
  -- filetype is keyfinder
  vim.api.nvim_buf_set_option(bufnr, "filetype", "keyfinder")

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)

  -- if vim.api.nvim_buf_is_valid(bufnr) then
  --   vim.api.nvim_buf_clear_namespace(bufnr, config.namespace, 0, -1)
  -- end

  local win_id = vim.api.nvim_open_win(bufnr, true, win_opts)

  vim.api.nvim_win_set_option(win_id, "winblend", config.options.window.winblend)

  -- map highlights if they aren't already defined
  local winhl = "NormalFloat:KeyfinderFloat"
  if vim.fn.hlexists("FloatBorder") == 1 then
    winhl = winhl .. ",FloatBorder:KeyfinderBorder"
  end
  vim.api.nvim_win_set_option(win_id, "winhighlight", winhl)

  vim.api.nvim_set_current_win(win_id)
  return win_id
end

--- Open the main display window
function Display:open()
  self:close()

  local start_row = 2
  self.original_win_id = vim.api.nvim_get_current_win()

  local lines = {}
  local keyboard_lines = self._keyboard:get_lines(false)
  local header_lines = get_header_lines(self._keyboard.width)
  local legend_lines = get_legend_lines(self._keyboard.width)
  if self.show_title then
    lines = header_lines
    start_row = start_row + #lines
  end
  for _, v in ipairs(keyboard_lines) do
    table.insert(lines, v)
  end
  if self.show_legend then
    for _, v in ipairs(legend_lines) do
      table.insert(lines, v)
    end
  end

  local vim_options = {
    window = {
      border = self.window.border,
    },
  }

  self.win_id = _create_window(lines, vim_options)

  vim.api.nvim_win_set_cursor(self.win_id, { start_row, 4 })

  self:set_mappings()
  self:highlight_buttons()
end

function Display:close()
  if self.win_id and vim.api.nvim_win_is_valid(self.win_id) then
    vim.api.nvim_win_close(self.win_id, true)
    self.win_id = nil
  end
end

function Display:set_mappings()
  local keymap_options = {
    nowait = true,
    noremap = true,
    silent = true,
    buffer = vim.api.nvim_win_get_buf(self.win_id),
  }

  local base_mappings = {
    ["<Esc>"] = function()
      self:close()
    end,
    ["<CR>"] = function()
      D.log("Display", "Enter presseed")
    end,
    ["<BS>"] = function()
      D.log("Backspace", "Backspace pressed")
    end,
  }

  for k, v in pairs(base_mappings) do
    vim.keymap.set("n", k, v, keymap_options)
  end

  local other_chars = "abcdefghijklmnopqrstuvwxyz,.[]\\"
  for i = 1, #other_chars do
    local k = string.sub(other_chars, i, i)
    D.log("Display", "Key pressed: %s", k)
  end
end

function Display:highlight_buttons()
  -- iterate over every button in the current_node
  for key_code, keymaps_info in pairs(self._keymaps.current_node) do
    self._keyboard:highlight(key_code, keymaps_info)
  end
end
return Display
