local lower_case = "`1234567890-=[]\\;',./"
local upper_case = '~!@#$%^&*()_+{}|:"<>?'

local key_cap_map = {
  ["lower"] = {},
  ["upper"] = {},
}

for i = 1, #lower_case, 1 do
  local lower_char = string.sub(lower_case, i, i)
  local upper_char = string.sub(upper_case, i, i)
  key_cap_map[lower_char] = {
    ["lower"] = lower_char,
    ["upper"] = upper_char,
  }
  key_cap_map[upper_char] = {
    ["lower"] = lower_char,
    ["upper"] = upper_char,
  }
end

---@class Keycap
---@field keylabel string
---@field upper string
---@field lower string
---@field row number
---@field start_col number
---@field end_col number
local Keycap = {}
Keycap.__index = Keycap

---@param keylabel string
function Keycap:new(keylabel)
  local lower = string.lower(keylabel)
  local upper = string.upper(keylabel)
  if vim.tbl_contains(key_cap_map, keylabel) then
    upper = key_cap_map[keylabel]["upper"]
    lower = key_cap_map[keylabel]["lower"]
  end

  local this = {
    keylabel = keylabel,
    lower = lower,
    upper = upper,
  }
  setmetatable(this, self)
  return this
end

function Keycap.to_lower(keylabel)
  if key_cap_map[keylabel] then
    return key_cap_map[keylabel]["lower"]
  else
    if vim.fn.strlen(keylabel) == 1 then
      return string.lower(keylabel)
    else
      return keylabel
    end
  end
end

function Keycap.to_upper(keylabel)
  if key_cap_map[keylabel] then
    return key_cap_map[keylabel]["upper"]
  else
    if vim.fn.strlen(keylabel) == 1 then
      return string.upper(keylabel)
    else
      return keylabel
    end
  end
end

return Keycap
