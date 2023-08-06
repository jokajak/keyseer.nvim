-- Configuration View:
--  keyseer.nvim  (H)   Details (D)   Configuration (C)   Help (?)
--
-- Configuration
--
-- Current mode: Normal
local Config = require("keyseer").config

-- Render configurations
local M = {}

-- TODO: Populate configurations
function M.render(ui)
  ui.render:append("Configuration", "KeySeerH2"):nl():nl()

  ui.render:append("Current configurations", "KeySeerH2"):nl():nl()

  ui.render:append("Current buffer: ", "KeySeerH2")
  ui.render:append(tostring(ui.state.bufnr)):nl()

  ui.render:append("mode for keymaps: ", "KeySeerH2")
  ui.render:append(tostring(ui.state.mode)):nl()

  ui.render:append("Show builtin keymaps: ", "KeySeerH2")
  ui.render:append(tostring(Config.include_builtin_keymaps)):nl()
  ui.render:append("Show global keymaps: ", "KeySeerH2")
  ui.render:append(tostring(Config.include_global_keymaps)):nl()
  ui.render:append("Show buffer keymaps: ", "KeySeerH2")
  ui.render:append(tostring(Config.include_buffer_keymaps)):nl()
end

return M
