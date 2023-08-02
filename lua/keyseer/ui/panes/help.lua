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
local UIConfig = require("keyseer.ui.config")

-- Render help
---@private
local M = {}

function M.render(ui)
  local display = ui.render
  display:append("Help", "KeySeerH2"):nl():nl()

  display:append("Colors depict the status of a keycap."):nl()

  display
    :append("Keycap ", "", { indent = 2 })
    :append("ex", "KeySeerKeycapKeymap")
    :append(" has a single keymap assigned.")
    :nl()
  display
    :append("Keycap ", "", { indent = 2 })
    :append("ex", "KeySeerKeycapMultipleKeymaps")
    :append(" has a multiple keymaps assigned.")
    :nl()

  display
    :append("Keycap ", "", { indent = 2 })
    :append("ex", "KeySeerKeycapKeymapsAndPrefix")
    :append(" has multiple keymaps assigned and is a prefix to more keymaps.")
    :nl()

  display
    :append("Keycap ", "", { indent = 2 })
    :append("ex", "KeySeerKeycapKeymapAndPrefix")
    :append(" has a keymap assigned and is a prefix to keymaps.")
    :nl()

  display
    :append("Keycap ", "", { indent = 2 })
    :append("ex", "KeySeerKeycapPrefix")
    :append(" is a prefix to keymaps.")
    :nl()

  display
    :append("You can press ")
    :append(UIConfig.keys.details, "KeySeerSpecial")
    :append(" on a key to show its details.")
    :nl()
    :nl()

  display
    :append("You can press ")
    :append(UIConfig.keys.close, "KeySeerSpecial")
    :append(" to close this window.")
    :nl()
    :nl()

  display:append("Keyboard Shortcuts", "KeySeerH2"):nl()
  for _, pane in ipairs(UIConfig.get_panes()) do
    if pane.key then
      local title = pane.name:sub(1, 1):upper() .. pane.name:sub(2)
      display:append("- ", "KeySeerSpecial", { indent = 2 })
      display:append(title, "Title")
      if pane.key then
        display:append(" <" .. pane.key .. ">", "KeySeerProp")
      end
      display:append(" " .. (pane.desc or "")):nl()
    end
  end

  display:nl()
end

return M
