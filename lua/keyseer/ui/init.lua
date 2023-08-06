-- This module is responsible for the UI
local Popup = require("keyseer.ui.popup")
local Render = require("keyseer.ui.render")
local UIConfig = require("keyseer.ui.config")
local D = require("keyseer.util.debug")
local Config = require("keyseer").config
local Keymaps = require("keyseer.keymaps")

-- This section of code is copied from https://github.com/folke/lazy.nvim/
-- Mad props and respect go to folke

---@class KeySeerUIState
---@field pane string Which pane to show
---@field prev_pane string The previous pane shown
---@field keyboard Keyboard The keyboard object
---@field keymaps Keymaps The keymaps
---@field current_keymaps table<string> The keymaps that have been added
---@field mode string The mode for displaying keymaps
---@field modifiers table{string,boolean} What modifier buttons are considered pressed
---@field bufnr buffer|nil The buffer
local default_state = {
  pane = "home",
  prev_pane = "",
  mode = "n",
  current_keymaps = {},
  modifiers = {
    ["<Ctrl>"] = false,
    ["<Shift>"] = false,
    ["<Alt>"] = false,
  },
  bufnr = nil,
}

---@class KeySeerUI: KeySeerPopup
---@field render KeySeerRender
---@field state KeySeerUIState
local KeySeerUI = {}

---@type KeySeerUI
---@private
KeySeerUI.ui = nil

---Returns if the ui visible
---@return boolean
---@private
function KeySeerUI.visible()
  return KeySeerUI.ui and KeySeerUI.ui.win and vim.api.nvim_win_is_valid(KeySeerUI.ui.win)
end

local function get_button_under_cursor(ui)
  local cursorposition = vim.fn.getcursorcharpos(ui.win)
  local row, col = cursorposition[2], cursorposition[3]
  -- size of the title is statically calculated
  local row_offset = 4
  D.log("UI", "Button row, col: " .. row - row_offset .. ", " .. col)
  ---@type Keyboard
  local keyboard = ui.state.keyboard
  local button = keyboard:get_keycap_at_position(row - row_offset, col)
  return button
end

---Show the KeySeer UI
---@param pane? string The starting pane
---@param mode? string The neovim mode for keymaps
---@param bufnr? integer The buffer for keymaps
function KeySeerUI.show(pane, mode, bufnr)
  bufnr = vim.F.if_nil(bufnr, vim.api.nvim_get_current_buf())
  KeySeerUI.ui = KeySeerUI.visible() and KeySeerUI.ui or KeySeerUI.create(bufnr)

  KeySeerUI.ui.state.mode = mode or KeySeerUI.ui.state.mode
  KeySeerUI.ui.state.pane = pane or KeySeerUI.ui.state.pane

  KeySeerUI.ui.state.bufnr = bufnr

  KeySeerUI.ui.state.keymaps:process_keymaps(bufnr, KeySeerUI.ui.state.mode)

  KeySeerUI.ui:update()
end

---Create the KeySeer UI
---@return KeySeerUI
---@param bufnr? buffer The buffer to retrieve keymaps
---@private
function KeySeerUI.create(bufnr)
  ---@type KeySeerUI|KeySeerPopup
  local self = setmetatable({}, { __index = setmetatable(KeySeerUI, { __index = Popup }) })
  bufnr = vim.F.if_nil(bufnr, vim.api.nvim_get_current_buf())

  self.state = vim.deepcopy(default_state)

  local keyboard = self.state.keyboard
  if not keyboard then
    local keyboard_opts = Config.keyboard
    local keyboard_options = vim.deepcopy(keyboard_opts)
    keyboard_options.layout = nil

    if type(keyboard_opts.layout) == "string" then
      keyboard = require("keyseer.keyboard." .. keyboard_opts.layout):new(keyboard_options)
    else
      ---@type Keyboard
      local layout = keyboard_opts.layout
      keyboard = layout:new(keyboard_options)
    end

    keyboard:get_lines(false)
    self.state.keyboard = keyboard
  end
  if not self.state.keymaps then
    self.state.keymaps = Keymaps:new()
  end

  local width = math.max(Config.ui.size.width, keyboard.width)
  local header_height = 0
  if Config.ui.show_header then
    header_height = 3
  else
    width = keyboard.width
  end
  local height = math.max(Config.ui.size.height, keyboard.height + header_height)

  ---@cast self KeySeerUI
  Popup.init(self, { size = { width = width, height = height } })

  self.render = Render.new(self)

  for k, v in pairs(UIConfig.panes) do
    self:on_key(v["key"], function()
      if self.state.pane == "home" then
        local button = get_button_under_cursor(self)
        if button then
          self.state.button = button
        end
      end
      self.state.prev_pane = self.state.pane
      self.state.pane = k
      self:update()
    end, v["desc"])
  end

  return self
end

---Update the KeySeer UI
---@private
function KeySeerUI:update()
  if self.buf and vim.api.nvim_buf_is_valid(self.buf) then
    if self.state.pane ~= self.state.prev_pane then
      local pane_available, pane = pcall(require, "keyseer.ui.panes." .. self.state.prev_pane)
      if pane_available and pane and vim.is_callable(pane.on_exit) then
        pane.on_exit(self)
      end
      pane_available, pane = pcall(require, "keyseer.ui.panes." .. self.state.pane)
      if pane_available and pane and vim.is_callable(pane.on_enter) then
        pane.on_enter(self)
      end
    end
    vim.bo[self.buf].modifiable = true
    self.render:update()
    vim.bo[self.buf].modifiable = false
    vim.cmd.redraw()
  end
end

---@type KeySeerUI
return KeySeerUI
