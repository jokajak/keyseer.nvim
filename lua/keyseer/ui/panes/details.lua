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

  ui.render:append("Details for <keycap>", "KeySeerH2"):nl()
end

return M
