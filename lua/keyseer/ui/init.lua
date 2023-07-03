-- This module is responsible for the UI
local Popup = require("keyseer.ui.popup")
local Render = require("keyseer.ui.render")
local UIConfig = require("keyseer.ui.config")

-- This section of code is copied from https://github.com/folke/lazy.nvim/
-- Mad props and respect go to folke

---@class KeySeerUIState
---@field pane string Which pane to show
---@field keyboard Keyboard The associated keyboard object
---@field mode string The mode for displaying keymaps
---@field modifiers table{string,boolean} What modifier buttons are considered pressed
local default_state = {
  pane = "home",
  mode = "n",
  modifiers = {
    ctrl = false,
    shift = false,
    alt = false,
  },
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

---@param pane? string
---@param mode? string
function M.show(pane, mode)
  M.ui = M.visible() and M.ui or M.create()

  if pane then
    M.ui.state.pane = pane
  end

  if mode then
    M.ui.state.mode = mode
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
      self.state.pane = k
      local button = self.render:get_button()
      if button then
        self.state.button = button
      end
      self:update()
    end, v["desc"])
  end

  -- keycap details
  self:on_key(UIConfig.keys.details, function()
    local button = self.render:get_button()
    if button then
      if button.is_modifier then
        self.state.modifiers[button.keycode] = not self.state.modifiers[button.keycode]
      else
        self.state.button = button
        self.state.pane = "details"
      end
      self:update()
    end
  end)
  return self
end

function M:update()
  if self.buf and vim.api.nvim_buf_is_valid(self.buf) then
    vim.bo[self.buf].modifiable = true
    self.render:update()
    vim.bo[self.buf].modifiable = false
    vim.cmd.redraw()
  end
end

return M
-- Main view:
--  keyseer.nvim  󰒲   Details (D)   Configuration (C)   Help (?)
--
-- ┌─────┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬────────┐
-- │  `  │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │ 7 │ 8 │ 9 │ 0 │ [ │ ] │  <BS>  │
-- ├─────┴───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┬────┤
-- │  <TAB>  │ ' │ , │ . │ p │ y │ f │ g │ c │ r │ l │ / │ = │  \ │
-- ├────────┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴───┴────┤
-- │ <CAPS> │ a │ o │ e │ u │ i │ d │ h │ t │ n │ s │ - │ <ENTER> │
-- ├────────┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴─────────┤
-- │  <SHIFT>  │ ; │ q │ j │ k │ x │ b │ m │ w │ v │ z │  <SHIFT> │
-- ├────────┬──┴───┴──┬┴───┴──┬┴───┴───┴───┴───┴─┬─┴───┴─┬────────┤
-- │ <CTRL> │ <SUPER> │ <ALT> │      <SPACE>     │ <ALT> │ <CTRL> │
-- └────────┴─────────┴───────┴──────────────────┴───────┴────────┘
--
-- Details View:
--  keyseer.nvim  (H)   Details (D)   Configuration (C)   Help (?)
--
-- Details for <key cap>
--
-- Current action: None
-- Number of prefixed actions: N
--
-- Configuration View:
--  keyseer.nvim  (H)   Details (D)   Configuration (C)   Help (?)
--
-- Configuration
--
-- Current mode: Normal
--
-- Help View:
--  keyseer.nvim  (H)   Details (D)   Configuration (C)   Help (?)
--
-- Help
--
-- Keyboard Shortcuts
--   - Home <H> Go back to main view
--   - Details <D> Show details of a current keycap
--   - Configuration <C> Change configuration
--   - Help <?> Toggle this help page
--
-- Color information goes here
--
-- ┌─────┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬────────┐
-- │  `  │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │ 7 │ 8 │ 9 │ 0 │ [ │ ] │  <BS>  │
-- ├─────┴───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┬────┤
-- │  <TAB>  │ ' │ , │ . │ p │ y │ f │ g │ c │ r │ l │ / │ = │  \ │
-- ├────────┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴───┴────┤
-- │ <CAPS> │ a │ o │ e │ u │ i │ d │ h │ t │ n │ s │ - │ <ENTER> │
-- ├────────┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴─────────┤
-- │  <SHIFT>  │ ; │ q │ j │ k │ x │ b │ m │ w │ v │ z │  <SHIFT> │
-- ├────────┬──┴───┴──┬┴───┴──┬┴───┴───┴───┴───┴─┬─┴───┴─┬────────┤
-- │ <CTRL> │ <SUPER> │ <ALT> │      <SPACE>     │ <ALT> │ <CTRL> │
-- └────────┴─────────┴───────┴──────────────────┴───────┴────────┘
