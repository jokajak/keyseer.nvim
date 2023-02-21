---@class KeyCode
---@field repr string[] The list of strings the key_code can appear in a neovim mapping
---@field key_cap KeyCap The keycap for this key_code
local KeyCode = {}

function KeyCode:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local key_lookup = setmetatable({
  C = "<Ctrl>",
  M = "<Alt>",
  Space = "<Space>",
  BS = "<BS>",
  [" "] = "<Space>",
}, {
  __index = function(_, k)
    return k
  end,
})

function KeyCode.from_str(keystr)
  local keys = {}
  local key = ""
  local escaped = false
  local in_special = false

  for i = 1, #keystr do
    local char = keystr:sub(i, i)

    if char == "<" and not escaped then
      if #key > 0 then
        table.insert(keys, { key_lookup[key] })
        key = ""
      end
      in_special = true
    elseif char == ">" and not escaped then
      if in_special then
        local special_keys = vim.split(key, "-")
        local key_symbols = {}
        for _, special_key in ipairs(special_keys) do
          local key_symbol = key_lookup[special_key]
          table.insert(key_symbols, key_symbol)
        end
        table.insert(keys, key_symbols)
        key = ""
      else
        key = key .. char
      end
      in_special = false
    elseif char == "\\" and not escaped then
      escaped = true
    else
      table.insert(keys, { key_lookup[char] })
      key = ""
      escaped = false
    end
  end

  if #key > 0 then
    table.insert(keys, { key_lookup[key] })
  end

  return keys
end

return KeyCode
