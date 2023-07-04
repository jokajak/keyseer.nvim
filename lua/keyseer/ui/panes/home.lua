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
local D = require("keyseer.util.debug")
local Config = require("keyseer").config
local Keymaps = require("keyseer.keymaps")
local Utils = require("keyseer.utils")
-- Render help
local M = {
  state = {
    count = 0,
  },
}

-- TODO: Populate main
function M.render(ui)
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

  local keymaps = Keymaps:new()
  keymaps:get_keymaps()
  keyboard:populate_lines(ui, keymaps:get_current_keycaps())
  ui.state.keyboard = keyboard
end

function M.on_enter(ui)
  M.state.count = M.state.count + 1
  Utils.notify("Entering home for the " .. M.state.count .. " time.")
end

function M.on_exit(ui)
  Utils.notify("Exiting home for the " .. M.state.count .. " time.")
end

return M
