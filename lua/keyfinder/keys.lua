-- for parsing keys
local presets = require("keyfinder.presets")

---@class keycaps
---@field key_presses table[table[string]]
---@field keys string

---@class mapping
---@field cmd string
---@field desc string
---@field id string
---@field keys keycaps
---@field prefix string

local M = {}

---Map keys into their order of being pressed
-- given a key string ",gb" or "<C-i>"
-- return a table of {[1] = ",", [2] = "g", [3] = "b"}
-- or {[1] = { "<C>", "i" }} respectively
---@param lhs string
---@return keycaps
function M.parse_keymap_lhs(lhs)
  local keys = {}
  local key = ""
  local in_special = false
  local pending_char = false

  local key_lookup = setmetatable({
    C = "<Ctrl>",
    M = "<Alt>",
    Space = "<Space>",
    BS = "<BS>",
    [" "] = "<Space>",
    [""] = "-", -- this gets added because of splitting on -
  }, {
    __index = function(_, k)
      return k
    end,
  })

  for i = 1, #lhs do
    local char = lhs:sub(i, i)

    if in_special then -- we're inside a <>
      if pending_char then -- we just saw a -, so we need to capture the next character
        key = key .. char
        pending_char = false
      else -- check the next character
        if char == ">" then -- if > then we are closing the combo
          -- split the keys by -
          local special_keys = vim.split(key, "-", { plain = true })
          -- get a table for storing the keys
          local key_symbols = {}
          -- iterate over the keys
          for j, special_key in ipairs(special_keys) do
            if special_key == "" then
              if j % 2 ~= 0 then
                local key_symbol = key_lookup[special_key]
                table.insert(key_symbols, key_symbol)
              end
            else
              -- map the symbol to a standard key
              local key_symbol = key_lookup[special_key]
              table.insert(key_symbols, key_symbol)
            end
          end
          -- add the keys to the result
          table.insert(keys, key_symbols)
          -- reset the key value
          key = ""
        else -- otherwise we are still collecting keys
          if char == "-" then -- if a - that means we need to store the next key
            pending_char = true
          end
          -- add the current character to the key
          key = key .. char
        end -- end > check
      end -- pending char check
    else -- not in a special
      if char == "<" then
        -- we're starting a combination of keys
        if #key > 0 then
          table.insert(keys, { key_lookup[key] })
          key = ""
        end
        in_special = true
      else -- not starting a combination of keys
        key = key .. char
        table.insert(keys, { key_lookup[key] })
        pending_char = false
        in_special = false
        key = ""
      end -- end combination check
    end -- end special check
  end

  -- if we have a key that needs to be saved
  if #key > 0 then
    table.insert(keys, { key_lookup[key] })
  end

  return keys
end

function M.extract_key_order(keystr)
  local keys = M.parse_keymap_lhs(keystr)
  local ret = {
    keys = keystr,
    key_presses = keys,
  }
  return ret
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
---Get keymaps with the given prefix
---@param keymaps mapping
---@param prefix string
---@return mapping[]
local function get_matching_keymaps(keymaps, prefix)
  local ret = {}

  for _, keymap in pairs(keymaps) do
    if keymap.lhs and vim.startswith(keymap.lhs, prefix) and #keymap.lhs > #prefix then
      local mapping = {
        id = keymap.lhs,
        prefix = keymap.lhs,
        cmd = keymap.rhs,
        desc = keymap.desc,
        keys = M.extract_key_order(string.sub(keymap.lhs, #prefix)),
      }
      table.insert(ret, mapping)
    end
  end
  return ret
end

-- local function pretty_print_table(t, prefix)
--   prefix = prefix or ""
--   local result = {}
--   for k, v in pairs(t) do
--     if type(v) == "table" then
--       table.insert(result, prefix .. tostring(k) .. ":")
--       for _, j in ipairs(pretty_print_table(v, prefix .. "  ")) do
--         table.insert(result, j)
--       end
--     else
--       table.insert(result, prefix .. tostring(k) .. ": " .. '"' .. tostring(v) .. '"')
--     end
--   end
--   return result
-- end

---Get keymaps
---@param mode string
---@param buf integer
---@param prefix string
---@return mapping[]
function M.get_mappings(mode, buf, prefix)
  local buffer_keymaps = buf and vim.api.nvim_buf_get_keymap(buf, mode) or {}
  local global_keymaps = vim.api.nvim_get_keymap(mode)
  prefix = prefix or ""

  -- create a table that returns an empty table for keys with no value
  local ret = setmetatable({}, {
    __index = function(_, _)
      return {}
    end,
  })

  local matching_buffer_keymaps = get_matching_keymaps(buffer_keymaps, prefix)

  -- local debug_buf = 878
  --
  -- vim.api.nvim_buf_set_lines(debug_buf, 0, -1, true, pretty_print_table(matching_buffer_keymaps))

  for _, mapping in ipairs(matching_buffer_keymaps) do
    -- ignore entries that exactly match the prefix
    for _, first_key in ipairs(mapping.keys.key_presses[1]) do
      local key_table = ret[first_key]
      table.insert(key_table, mapping)
      ret[first_key] = key_table
    end
  end

  local matching_global_keymaps = get_matching_keymaps(global_keymaps, prefix)
  for _, mapping in ipairs(matching_global_keymaps) do
    for _, first_key in ipairs(mapping.keys.key_presses[1]) do
      local key_table = ret[first_key]
      table.insert(key_table, mapping)
      ret[first_key] = key_table
    end
  end

  local matching_preset_keymaps = get_matching_keymaps(presets[mode], prefix)
  for _, mapping in ipairs(matching_preset_keymaps) do
    for _, first_key in ipairs(mapping.keys.key_presses[1]) do
      local key_table = ret[first_key]
      table.insert(key_table, mapping)
      ret[first_key] = key_table
    end
  end

  return ret
end

return M
