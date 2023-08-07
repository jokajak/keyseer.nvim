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

---@param keystring string The keystring to find the keycode
---@return string keycode The found keycode or empty string if none found.
function Keypress.get_keycode(keystring)
  local keycode = ""
  -- local modifiers = {}
  local key_presses = Utils.parse_keystring(keystring, true)
  if string.match(keystring, "Þ") or string.match(keystring, "<plug>") then
    return keycode
  end

  local long_keycodes = {
    "Up",
    "Down",
    "Left",
    "Right",
    "<Space>",
    "<Esc>",
    "<F1>",
    "<F2>",
    "<F3>",
    "<F4>",
    "<F5>",
    "<F6>",
    "<F7>",
    "<F8>",
    "<F9>",
    "<F10>",
    "<CR>",
    "<Tab>",
    "<BS>",
  }

  if #key_presses > 1 then
    Utils.notify("Too many keypresses: " .. keystring)
    return keycode
  end

  local found_keycode = nil
  for _, key in pairs(key_presses[1]) do
    if key == "<lt>" then
      key = "<"
    end
    if vim.tbl_contains(long_keycodes, key) then
      found_keycode = key
    end

    if Buttons.shifted_keys:find(key, 0, true) or Buttons.unshifted_keys:find(key, 0, true) then
      if found_keycode then
        Utils.notify(
          "Found more than one keycode in a keystring, this shouldn't happen.",
          { level = vim.log.ERROR }
        )
      else
        found_keycode = key
      end
    end
  end

  return found_keycode
end

return Keypress
