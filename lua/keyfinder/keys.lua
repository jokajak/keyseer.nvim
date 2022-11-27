-- for parsing keys
local strsub = string.sub
local presets = require("keyfinder.presets")

---@class Keys
local M = {}

-- extract all keys in a special key
local function split_key_str(keystr)
  local keys = {}
  local current_key = ""
  local combination = false

  for i = 1, #keystr, 1 do
    local char = strsub(keystr, i, i)
    if char == "-" then
      current_key = current_key .. ">"
      table.insert(keys, current_key)
      current_key = ""
      combination = true
    elseif char == ">" then
      if not combination then
        current_key = current_key .. char
      end
      table.insert(keys, current_key)
    else
      current_key = current_key .. char
    end
  end
  return keys
end

-- map keys into their order of being pressed
-- given a key string ",gb" or "<C-i>"
-- return a table of {[1] = ",", [2] = "g", [3] = "b"}
-- or {[1] = { "<C>", "i" }} respectively
function M.extract_key_order(keystr)
  local keys = {}
  local special = nil
  local current_key = ""
  local pending_keys = 1

  for i = 1, #keystr, 1 do
    local char = strsub(keystr, i, i)
    if special then -- inside a <>
      if pending_keys == 0 then
        if char == ">" then -- finish a <>
          table.insert(keys, special .. ">")
          current_key = ""
          pending_keys = 1
          special = nil
        elseif char == "-" then
          -- if inside a <> then it could be <C-t>
          -- which means special is true and the *next* character is a modified
          -- so we want to try to capture it in the next loop
          pending_keys = 1
        end
      else
        pending_keys = 0
      end
      if special then
        special = special .. char
      end
    elseif char == "<" then
      special = "<"
      -- prepare to get the next key
      pending_keys = 0
    else
      current_key = current_key .. char
      pending_keys = pending_keys - 1
      if pending_keys == 0 then
        table.insert(keys, current_key)
        current_key = ""
        pending_keys = 1
      end
    end
  end
  local ret = { keys = keys, keycaps = {} }
  for _, key in pairs(keys) do
    if key == " " then
      key = "<SPACE>"
    elseif key == "<C>" then
      key = "<LCTRL>"
    end
    if key:len() == 1 then
      key = key:lower()
      table.insert(ret.keycaps, { key })
    else
      table.insert(ret.keycaps, split_key_str(key))
    end
  end
  return ret
end

local function starts_with(str, start)
  return str:sub(1, #start) == start
end

local function make_pattern_safe(str)
  -- ( ) . % + - * ? [ ^ $
  return string.gsub(str, "[%(|%)|\\|%[|%]|%-|%{%}|%?|%+|%*|%^|%$|%.]", {
    ["\\"] = "%\\",
    ["-"] = "%-",
    ["("] = "%(",
    [")"] = "%)",
    ["["] = "%[",
    ["]"] = "%]",
    ["{"] = "%{",
    ["}"] = "%}",
    ["?"] = "%?",
    ["+"] = "%+",
    ["*"] = "%*",
    ["^"] = "%^",
    ["$"] = "%$",
    ["."] = "%.",
  })
end

--[[ {
  buffer = 0,
  expr = 0,
  lhs = '"',
  lhsraw = '"',
  lnum = 0,
  mode = "n",
  noremap = 1,
  nowait = 0,
  rhs = 'rhs',
  script = 0,
  sid = -8,
  silent = 1
} ]]
local function get_matching_keymaps(keymaps, prefix)
  local ret = {}

  local prefix_pattern = make_pattern_safe(prefix)
  for _, keymap in pairs(keymaps) do
    if keymap.lhs and starts_with(keymap.lhs, prefix) and #keymap.lhs > #prefix then
      local mapping = {
        id = keymap.lhs,
        prefix = keymap.lhs,
        cmd = keymap.rhs,
        desc = keymap.desc,
        keys = M.extract_key_order(string.gsub(keymap.lhs, prefix_pattern, "", 1)),
      }
      table.insert(ret, mapping)
    end
  end
  return ret
end

function M.get_mappings(mode, buf, prefix)
  local buffer_keymaps = buf and vim.api.nvim_buf_get_keymap(buf, mode) or {}
  local global_keymaps = vim.api.nvim_get_keymap(mode)
  prefix = prefix or ""

  local ret = {}

  local matching_buffer_keymaps = get_matching_keymaps(buffer_keymaps, prefix)

  for _, mapping in ipairs(matching_buffer_keymaps) do
    -- ignore entries that exactly match the prefix
    for _, first_key in pairs(mapping.keys.keycaps[1]) do
      local key_table = ret[first_key] or {}
      table.insert(key_table, mapping)
      ret[first_key] = key_table
    end
  end

  local matching_global_keymaps = get_matching_keymaps(global_keymaps, prefix)
  for _, mapping in ipairs(matching_global_keymaps) do
    for _, first_key in pairs(mapping.keys.keycaps[1]) do
      local key_table = ret[first_key] or {}
      table.insert(key_table, mapping)
      ret[first_key] = key_table
    end
  end

  local matching_preset_keymaps = get_matching_keymaps(presets[mode], prefix)
  for _, mapping in ipairs(matching_preset_keymaps) do
    for _, first_key in pairs(mapping.keys.keycaps[1]) do
      local key_table = ret[first_key] or {}
      table.insert(key_table, mapping)
      ret[first_key] = key_table
    end
  end

  return ret
end

return M
