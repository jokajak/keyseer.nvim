-- This module is responsible for the UI
local Popup = require("keyseer.ui.popup")
local Render = require("keyseer.ui.render")
local UIConfig = require("keyseer.ui.config")
local Utils = require("keyseer.utils")
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
    ctrl = false,
    shift = false,
    alt = false,
  },
  bufnr = nil,
}
--
---@class KeySeerUI: KeySeerPopup
---@field render KeySeerRender
---@field state KeySeerUIState
local M = {}

---@type KeySeerUI
M.ui = nil

---@return boolean
function M.visible()
  return M.ui and M.ui.win and vim.api.nvim_win_is_valid(M.ui.win)
end

---@param pane? string The starting pane
---@param mode? string The neovim mode for keymaps
---@param bufnr? integer The buffer for keymaps
function M.show(pane, mode, bufnr)
  M.ui = M.visible() and M.ui or M.create()

  if pane then
    M.ui.state.pane = pane
  end

  if mode then
    M.ui.state.mode = mode
  end

  if bufnr then
    M.ui.state.bufnr = bufnr
  end

  M.ui:update()
end

---@return KeySeerUI
function M.create()
  local self = setmetatable({}, { __index = setmetatable(M, { __index = Popup }) })
  ---@cast self KeySeerUI
  Popup.init(self, {})

  self.state = vim.deepcopy(default_state)

  self.render = Render.new(self)

  for k, v in pairs(UIConfig.panes) do
    self:on_key(v["key"], function()
      if self.state.pane == "home" then
        local button = self.render:get_button()
        if button then
          self.state.button = button
        end
      end
      self.state.prev_pane = self.state.pane
      self.state.pane = k
      self:update()
    end, v["desc"])

    if not self.state.keyboard then
      local keyboard_opts = Config.keyboard
      local keyboard
      local keyboard_options = vim.deepcopy(keyboard_opts)
      keyboard_options.layout = nil

      if type(keyboard_opts.layout) == "string" then
        keyboard = require("keyseer.keyboard." .. keyboard_opts.layout):new(keyboard_options)
      else
        ---@type Keyboard
        local layout = keyboard_opts.layout
        keyboard = layout:new(keyboard_options)
      end

      self.state.keyboard = keyboard
    end
    if not self.state.keymaps then
      self.state.keymaps = Keymaps:new()
      self.state.keymaps:process_keymaps(self.state.bufnr)
    end
  end

  -- open details for the keycap under the cursor
  self:on_key(UIConfig.keys.details, function()
    if self.state.pane == "home" then
      local button = self.render:get_button()
      if button then
        if button.is_modifier then
          self.state.modifiers[button.keycode] = not self.state.modifiers[button.keycode]
        else
          self.state.button = button
          self.state.prev_pane = self.state.pane
          self.state.pane = "details"
        end
        self:update()
      end
    end
  end)

  -- go backwards in the key press tree
  self:on_key(UIConfig.keys.back, function()
    -- only makes sense on the home pane
    if self.state.pane == "home" then
      Utils.notify("Going back")
      self.state.keymaps:pop()
      self:update()
    end
  end)
  return self
end

function M:update()
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

return M
