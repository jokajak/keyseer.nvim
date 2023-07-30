-- Main view:
--  keyseer.nvim  󰒲   Details (D)   Configuration (C)   Help (?)
--
-- ┌─────┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬────────┐
-- │  `  │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │ 7 │ 8 │ 9 │ 0 │ [ │ ] │  <BS>  │
-- ├─────┴───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┬────┤
-- │ <TAB>   │ ' │ , │ . │ p │ y │ f │ g │ c │ r │ l │ / │ = │  \ │
-- ├────────┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴───┴────┤
-- │ <CAPS> │ a │ o │ e │ u │ i │ d │ h │ t │ n │ s │ - │ <ENTER> │
-- ├────────┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴─────────┤
-- │ <SHIFT>   │ ; │ q │ j │ k │ x │ b │ m │ w │ v │ z │  <SHIFT> │
-- ├────────┬──┴───┴──┬┴───┴──┬┴───┴───┴───┴───┴─┬─┴───┴─┬────────┤
-- │ <CTRL> │ <SUPER> │ <ALT> │      <SPACE>     │ <ALT> │ <CTRL> │
-- └────────┴─────────┴───────┴──────────────────┴───────┴────────┘
local D = require("keyseer.util.debug")
local UIConfig = require("keyseer.ui.config")
-- Render help
local M = {
  count = 0,
  modifiers = {},
}

function M.render(ui)
  local current_keycaps = ui.state.keymaps:get_current_keycaps(ui.state.modifiers)
  local height, width = ui.state.keyboard:populate_lines(ui, current_keycaps)

  -- ui.state.keymaps:add_stats(ui)

  ui.win_opts.height = height - 1
  ui.opts.size.height = height - 1
  if width ~= 0 then
    ui.win_opts.width = width
    ui.opts.size.width = width
  end
  ui:layout()
  for _, keypress in pairs(ui.state.current_keymaps) do
    vim.keymap.del("n", "g" .. keypress, { buffer = ui.buf })
  end
  ui.state.current_keymaps = {}
  for _, keypress in pairs(ui.state.keymaps:get_current_keypresses()) do
    -- D.log("UI", "adding keymap for %s", keypress)
    table.insert(ui.state.current_keymaps, keypress)
    vim.keymap.set("n", "g" .. keypress, function()
      ui.state.keymaps:push(keypress)
      ui:update()
    end, { buffer = ui.buf })
  end
end

local function get_button_under_cursor(ui)
  local cursorposition = vim.fn.getcursorcharpos(ui.win)
  local row, col = cursorposition[2], cursorposition[3]
  -- size of the title is statically calculated
  local row_offset = 4
  ---@type Keyboard
  local keyboard = ui.state.keyboard
  local button = keyboard:get_keycap_at_position(row - row_offset, col)
  return button
end

---Update keymaps when entering the pane
function M.on_enter(ui)
  -- for _, keypress in pairs(ui.state.current_keymaps) do
  --   vim.keymap.set("n", "g" .. keypress, function()
  --     ui.state.keymaps:push(keypress)
  --     ui:update()
  --   end, { buffer = ui.buf })
  -- end
  -- go backwards in the key press tree
  vim.keymap.set("n", UIConfig.keys.back, function()
    -- only makes sense on the home pane
    ui.state.keymaps:pop()
    ui:update()
  end, { buffer = ui.buf })

  -- open details for the keycap under the cursor
  vim.keymap.set("n", UIConfig.keys.details, function()
    local button = get_button_under_cursor(ui)
    if button then
      if button.is_modifier then
        ui.state.modifiers[button.keycode] = not ui.state.modifiers[button.keycode]
      else
        ui.state.button = button
        ui.state.prev_pane = ui.state.pane
        ui.state.pane = "details"
      end
      ui:update()
    end
  end, { buffer = ui.buf })
end

---Update keymaps when exiting the pane
function M.on_exit(ui)
  for _, keypress in pairs(ui.state.current_keymaps) do
    -- D.log("UI", "deleting keymap for %s", keypress)
    vim.keymap.del("n", "g" .. keypress, { buffer = ui.buf })
  end
  ui.state.current_keymaps = {}
  vim.keymap.del("n", UIConfig.keys.back, { buffer = ui.buf })
  vim.keymap.del("n", UIConfig.keys.details, { buffer = ui.buf })
end

return M
