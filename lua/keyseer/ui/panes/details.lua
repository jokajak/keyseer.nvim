-- Details View:
--  keyseer.nvim  (H)   Details (D)   Configuration (C)   Help (?)
--
-- Details for <key cap>
--
-- Current action: None
-- Number of prefixed actions: N

-- Render details
local M = {}

-- TODO: Populate details
function M.render(ui)
  ui.render:append("Details", "KeySeerH2"):nl():nl()

  if ui.state.button then
    ui.render:append("Details for ", "KeySeerH2")
    ui.render:append(tostring(ui.state.button), "KeySeerH2"):nl():nl()

    local keymaps = ui.state.keymaps:get_keymaps(ui.state.button.keycode) or {}
    for _, keymap in pairs(keymaps) do
      if keymap.desc then
        ui.render:append(keymap.desc):append(": ")
      end
      if keymap.rhs then
        ui.render:append(keymap.rhs)
      elseif keymap.callback then
        ui.render:append("Lua function")
      else
        vim.print(keymap)
      end
      ui.render:nl():nl()
    end
  else
    ui.render:append("No button currently under cursor."):nl()
  end
end

return M
