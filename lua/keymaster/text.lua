local Text = {}
Text.__index = Text

function Text.len(str)
  return vim.fn.strwidth(str)
end

---@class Text
---@field lines string[]
---@field width number
function Text:new()
  local this = {
    lines = {},
    width = 0,
  }
  setmetatable(this, self)
  return this
end

function Text:set(row, line)
  -- extend lines if needed
  for i = 1, row, 1 do
    if not self.lines[i] then
      self.lines[i] = ""
    end
  end

  self.lines[row] = line

  if Text.len(line) > self.width then
    self.width = Text.len(line)
  end
end

function Text:append(line)
  table.insert(self.lines, line)

  if Text.len(line) > self.width then
    self.width = Text.len(line)
  end
end

return Text
