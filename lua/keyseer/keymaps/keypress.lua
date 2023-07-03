local Buttons = require("keyseer.util.buttons")
local Utils = require("keyseer.utils")

-- The Keypress class does the work of converting the neovim keystrings to key presses
---@class Keypress
---@field keystring string The string of keys for a key press
---@field modifiers table<string,boolean> The table of modifiers
local Keypress = {}

---@param keystring string The keystring to be parsed
---@return Keypress
function Keypress.new(keystring)
  local self = setmetatable({}, {
    __index = Keypress,
  })

  vim.validate({ Keypress = { keystring, "string", true } })
  self.keystring = keystring

  return self
end

---@param keystring string The keystring to extract modifiers from
---@return table<string,boolean>
function Keypress.get_modifiers(keystring)
  local modifiers = {}
  local key_presses = Utils.parse_keystring(keystring, true)
  if string.match(keystring, "Þ") then
    return modifiers
  end

  if #key_presses > 1 then
    Utils.notify("Too many keypresses: " .. keystring)
    return {}
  end

  for _, key in pairs(key_presses[1]) do
    if Buttons.shifted_keys:find(key, 0, true) then
      -- shift button is currently pressed
      modifiers["<Shift>"] = true
    end
    if key == "<Ctrl>" or key == "<Meta>" then
      modifiers[key] = true
    end
  end

  return modifiers
end

return Keypress
