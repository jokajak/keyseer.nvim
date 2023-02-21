-- Key cap model and methods
---@class KeyCap
---@field symbol string the output to display
---@field code KeyCode the neovim key codes
---@field button string the button on a layout
local KeyCap = {}

function KeyCap:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

return KeyCap
