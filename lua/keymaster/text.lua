---@class Highlight
---@field group string
---@field line number
---@field from number
---@field to number

---@class Text
---@field lines string[]
---@field width number
---@field hl Highlight[]
local Text = {}
Text.__index = Text

function Text.len(str)
  return vim.fn.strwidth(str)
end

function Text:new()
  local this = {
    lines = {},
    hl = {},
    width = 0,
  }
  setmetatable(this, self)
  return this
end

function Text:set(row, line, group)
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

  if not group then
    return
  end

  self:highlight(row, line, "Keymaster" .. group)
end

function Text:append(line)
  table.insert(self.lines, line)

  if Text.len(line) > self.width then
    self.width = Text.len(line)
  end
end

function Text:highlight(row, from, to, group)
  local line = self.lines[row]
  local before = vim.fn.strcharpart(line, 0, from)
  local str = vim.fn.strcharpart(line, 0, to)
  from = vim.fn.strlen(before)
  to = vim.fn.strlen(str)
  table.insert(self.hl, {
    line = row - 1,
    from = from,
    to = to,
    group = group,
  })
end

return Text
