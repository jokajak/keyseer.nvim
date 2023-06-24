local Utils = {}

---Justify a list of strings
---@param width number The width of the display
---@param words string[] The list of strings to justify
---@return string The justified string
function Utils.justify(width, words)
  local word_list = words
  if type(words) == "string" then
    word_list = vim.split(words, " ", {})
  end

  local lines = {}
  local currentLine = ""
  for _, word in ipairs(word_list) do
    -- check if adding this word will make the line too long
    if #currentLine + #word + 1 <= width then
      -- add the word and a space to the current line
      if #currentLine > 0 then
        currentLine = currentLine .. " "
      end
      currentLine = currentLine .. word
    else
      -- add the current line to the list of lines and start a new line
      table.insert(lines, currentLine)
      currentLine = word
    end
  end

  -- add the last line
  table.insert(lines, currentLine)

  -- pad spaces between words to make each line exactly the specified width
  for i, line in ipairs(lines) do
    local wordsInLine = {}
    for word in line:gmatch("%S+") do
      table.insert(wordsInLine, word)
    end

    if #wordsInLine > 1 then
      local totalSpaces = width - #line
      local spacesToAdd = totalSpaces / (#wordsInLine - 1)
      local extraSpaces = totalSpaces % (#wordsInLine - 1)
      local newLine = wordsInLine[1]

      for j = 2, #wordsInLine do
        if j <= extraSpaces + 1 then
          newLine = newLine .. string.rep(" ", spacesToAdd + 1) .. wordsInLine[j]
        else
          newLine = newLine .. string.rep(" ", spacesToAdd) .. wordsInLine[j]
        end
      end

      lines[i] = newLine
    end
  end

  -- return the justified text as a single string
  return table.concat(lines, "\n")
end

---Utility function to parse a keystring into a table of keycodes
---@return table Keycodes in the key string
function Utils.parse_keystring(keystr)
  local keys = {}
  local key = ""
  local in_special = false
  local pending_char = false

  local key_lookup = setmetatable({
    C = "<Ctrl>",
    M = "<Meta>",
    Space = "<Space>",
    BS = "<BS>",
    [" "] = "<Space>",
    [""] = "-", -- this gets added because of splitting on -
  }, {
    __index = function(_, k)
      return k
    end,
  })

  for i = 1, #keystr do
    local char = keystr:sub(i, i)

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

  if #key > 0 then
    table.insert(keys, { key_lookup[key] })
  end

  return keys
end

---Sanity check the mode
---@param mode string the mode
function Utils.check_mode(mode)
  if not ("niv"):find(mode) then
    return false
  else
    return true
  end
end

function Utils.keytree(keystr)
  -- Parse the keystring using Utils.parse_keystring
  local parsed_keystr = Utils.parse_keystring(keystr)

  -- Initialize an empty table for the nested keymap
  local ret = {}

  local current_node = ret
  local next_node = ret
  -- Iterate over the parsed keystr and build the nested keymap
  for _, key_list in ipairs(parsed_keystr) do
    local modifiers = {}
    for i, key in ipairs(key_list) do
      -- Skip keys that include both < and > in the key
      local is_modifier = (key == "<Ctrl>" or key == "<Meta>" or key == "<Shift>" or key == "<Alt>")

      if is_modifier then
        modifiers[key] = true
      else
        if not current_node[key] then
          current_node[key] = { modifiers = {}, children = {} }
        end
        for modifier, _ in pairs(modifiers) do
          current_node[key].modifiers[modifier] = true
        end
        -- Store the reference for the next node.
        -- This way modifiers could come later
        next_node = current_node[key].children
      end
    end
    current_node = next_node
  end

  return ret
end

return Utils
