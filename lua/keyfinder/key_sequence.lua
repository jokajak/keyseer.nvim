local KeyCode = require("keyfinder.key_codes")
---@class KeySequence
---@field key_codes KeyCode[] The key codes that comprise the sequence
---@field keystr string The keys in the sequence as reported by neovim
local KeySequence = {}

function KeySequence:new(o, keystr)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.keystr = keystr
  self.key_codes = KeyCode.from_str(keystr)
  return o
end

return KeySequence
