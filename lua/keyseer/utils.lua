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
---@param keystr string The key string to be split
---@param split_keypresses boolean? control if key presses are returned as a keypress or a table of keycaps
---@return table Keycodes in the key string
function Utils.parse_keystring(keystr, split_keypresses)
  local keys = {}
  local key = ""
  local in_special = false
  local pending_char = false
  split_keypresses = vim.F.if_nil(split_keypresses, true)

  local key_lookup = setmetatable({
    -- add the <> back
    ["Space"] = "<Space>",
    ["Esc"] = "<Esc>",
    ["BS"] = "<BS>",
    ["lt"] = "<lt>",
    ["F1"] = "<F1>",
    ["F2"] = "<F2>",
    ["F3"] = "<F3>",
    ["F4"] = "<F4>",
    ["F5"] = "<F5>",
    ["F6"] = "<F6>",
    ["F7"] = "<F7>",
    ["F8"] = "<F8>",
    ["F9"] = "<F9>",
    ["F10"] = "<F10>",
    [" "] = "<Space>",
    [""] = "-", -- this gets added because of splitting on `-`
  }, {
    __index = function(_, k)
      return k
    end,
  })
  local modifier_lookup = setmetatable({
    C = "<Ctrl>",
    M = "<Meta>",
  }, {
    __index = function(_, k)
      return key_lookup[k]
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
          local key_symbols = {}
          if split_keypresses then
            -- split the keys by -
            local special_keys = vim.split(key, "-", { plain = true })
            -- get a table for storing the keys
            -- iterate over the keys
            for j, special_key in ipairs(special_keys) do
              if special_key == "" then
                if j % 2 ~= 0 then
                  local key_symbol = modifier_lookup[special_key]
                  table.insert(key_symbols, key_symbol)
                end
              else
                -- map the symbol to a standard key
                local key_symbol = modifier_lookup[special_key]
                table.insert(key_symbols, key_symbol)
              end
            end
          else
            table.insert(key_symbols, "<" .. key .. ">")
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

function Utils.wo(win, k, v)
  if vim.api.nvim_set_option_value then
    vim.api.nvim_set_option_value(k, v, { scope = "local", win = win })
  else
    vim.wo[win][k] = v
  end
end

---@alias KeySeerNotifyOpts {lang?:string, title?:string, level?:number}

---@param msg string|string[]
---@param opts? KeySeerNotifyOpts
function Utils.notify(msg, opts)
  if vim.in_fast_event() then
    return vim.schedule(function()
      Utils.notify(msg, opts)
    end)
  end

  opts = opts or {}
  if type(msg) == "table" then
    msg = table.concat(
      vim.tbl_filter(function(line)
        return line or false
      end, msg),
      "\n"
    )
  end
  local lang = opts.lang or "markdown"
  vim.notify(msg, opts.level or vim.log.levels.INFO, {
    on_open = function(win)
      pcall(require, "nvim-treesitter")
      vim.wo[win].conceallevel = 3
      vim.wo[win].concealcursor = ""
      vim.wo[win].spell = false
      local buf = vim.api.nvim_win_get_buf(win)
      if not pcall(vim.treesitter.start, buf, lang) then
        vim.bo[buf].filetype = lang
        vim.bo[buf].syntax = lang
      end
    end,
    title = opts.title or "keyseer.nvim",
  })
end

---@param msg string|string[]
---@param opts? KeySeerNotifyOpts
function Utils.error(msg, opts)
  opts = opts or {}
  opts.level = vim.log.levels.ERROR
  Utils.notify(msg, opts)
end

function Utils.default_table()
  return setmetatable({}, {
    -- ensure every entry in the table is a table
    __index = function(tbl, key)
      local new_tbl = {}
      rawset(tbl, key, new_tbl)
      return new_tbl
    end,
  })
end

---Get the start column and end column in bytes
---@param line string The string of characters to find byte positions
---@param from number The start column
---@param to number The end column
---@return number start_col the start column in bytes
---@return number end_col the end column in bytes
function Utils.get_str_bytes(line, from, to)
  -- Because the separators are multi-byte strings,
  -- we have to do a conversion for highlighting purposes
  local before = vim.fn.strcharpart(line, 0, from)
  local str = vim.fn.strcharpart(line, 0, to)
  from = vim.fn.strlen(before)
  to = vim.fn.strlen(str)
  return from, to
end

return Utils
