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

return Utils
