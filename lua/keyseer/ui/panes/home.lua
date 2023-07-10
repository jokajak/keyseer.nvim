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
  ui.state.keyboard:populate_lines(ui, current_keycaps)
  for _, keypress in pairs(ui.state.current_keymaps) do
    vim.keymap.del("n", "g" .. keypress, { buffer = ui.buf })
  end
  ui.state.current_keymaps = {}
  for _, keypress in pairs(ui.state.keymaps:get_current_keypresses()) do
    D.log("UI", "adding keymap for %s", keypress)
    table.insert(ui.state.current_keymaps, keypress)
    vim.keymap.set("n", "g" .. keypress, function()
      ui.state.keymaps:push(keypress)
      ui:update()
    end, { buffer = ui.buf })
  end
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
end

---Update keymaps when exiting the pane
function M.on_exit(ui)
  for _, keypress in pairs(ui.state.current_keymaps) do
    D.log("UI", "deleting keymap for %s", keypress)
    vim.keymap.del("n", "g" .. keypress, { buffer = ui.buf })
  end
  ui.state.current_keymaps = {}
  vim.keymap.del("n", UIConfig.keys.back, { buffer = ui.buf })
end

return M
