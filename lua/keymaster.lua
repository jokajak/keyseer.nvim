local layouts = require("keymaster.layouts")
local display = require("keymaster.display")

local M = {}

local function with_defaults(options)
  return {
    name = options.name or "John Doe",
    layout = options.layout or "qwerty"
  }
end

-- This function is supposed to be called explicitly by users to configure this
-- plugin
function M.setup(options)
  M.options = with_defaults(options)
end

function M.is_configured()
  return M.options ~= nil
end

-- This is a function that will be used outside this plugin code.
-- Think of it as a public API
function M.display(mode)
  if not M.is_configured() then
    return
  end

  local mode = mode or "normal"

  local display = display.render(M.options.layout)
  print(display)
end

M.options = nil

return M
