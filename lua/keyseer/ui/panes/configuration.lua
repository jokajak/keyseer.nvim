-- Configuration View:
--  keyseer.nvim  (H)   Details (D)   Configuration (C)   Help (?)
--
-- Configuration
--
-- Current mode: Normal

-- Render configurations
local M = {}

-- TODO: Populate configurations
function M.render(ui)
  ui.render:append("Configuration", "KeySeerH2"):nl():nl()

  ui.render:append("Current configurations", "KeySeerH2"):nl()
end

return M
