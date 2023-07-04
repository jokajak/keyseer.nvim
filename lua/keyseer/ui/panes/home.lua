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
  count = 0,
  modifiers = {},
  saved_keymaps = {},
}

function M.ensure_state(ui)
  if not ui.state.keyboard then
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

    ui.state.keyboard = keyboard
  end
  if not ui.state.keymaps then
    ui.state.keymaps = Keymaps:new()
    ui.state.keymaps:process_keymaps()
  end
end

-- TODO: Populate main
function M.render(ui)
  M.ensure_state(ui)
  local current_keycaps = ui.state.keymaps:get_current_keycaps(ui.state.modifiers)
  ui.state.keyboard:populate_lines(ui, current_keycaps)
end

---Update keymaps when entering the pane
function M.on_enter(ui)
  M.ensure_state(ui)
  Utils.notify("Entering home")
end

---Update keymaps when exiting the pane
function M.on_exit(ui)
  Utils.notify("Exiting home")
end

return M
