local D = require("keyseer.util.debug")
local Config = require("keyseer").config
local Keymaps = require("keyseer.keymaps")
-- Render help
local M = {}

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

return M
