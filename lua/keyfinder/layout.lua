local Config = require("keyfinder.config")
local Text = require("keyfinder.text")
local Keycaps = require("keyfinder.keycaps")
-- this file generates the keyboard display
local strrep = string.rep
local max = math.max

local charset = {
  -- [ up down left right ] = char
  --      s : single
  ["    "] = " ",
  ["ss  "] = "│",
  [" ss "] = "┐",
  ["  ss"] = "─",
  ["s s "] = "┘",
  ["s  s"] = "└",
  [" s s"] = "┌",
  ["sss "] = "┤",
  ["ss s"] = "├",
  ["s ss"] = "┴",
  [" sss"] = "┬",
  ["ssss"] = "┼",
}

local function get_line(opts)
  return charset[table.concat(opts, "")]
end

---@class Layout
---@field options Options
---@field text Text
---@field layout string[]
---@field keycap_layout string[]
---@field keycap_positions table[]
---@field keycaps Keycap[]
---@field regions table[]
local Layout = {}
Layout.__index = Layout

---@param options? Options
function Layout:new(options)
  local defaults = Config.options
  options = vim.tbl_deep_extend("force", {}, defaults, options or {})
  local this = {
    options = options,
    text = Text:new(),
    keycap_layout = options.layout,
    layout = {},
    keycap_positions = {},
    regions = {},
  }
  setmetatable(this, self)
  return this
end

local function center(str, width, shift_left)
  local total_padding = width - Text.len(str)
  local small_pad = math.floor(total_padding / 2)
  local big_pad = math.ceil(total_padding / 2)
  if shift_left then
    return strrep(" ", small_pad) .. str .. strrep(" ", big_pad), small_pad, big_pad
  else
    return strrep(" ", big_pad) .. str .. strrep(" ", small_pad), big_pad, small_pad
  end
end

-- This function calculates the highlighted keycap position
-- I hate string versus bytes
function Layout.calculate_byte_position(row_text, keycap_position, highlight_padding)
  local left_padding = keycap_position["left_pad"]
  local right_padding = keycap_position["right_pad"]
  local keycap = keycap_position["keycap"]
  local left_highlight_padding = math.max(0, Text.len(left_padding) - highlight_padding[2])
  -- Calculate the offset to the right
  -- minimum of the highlight padding to the right and the available padding
  local right_highlight_padding = math.min(Text.len(right_padding), highlight_padding[4])

  row_text = row_text .. charset["ss  "]
  local start_col = Text.len(row_text) + Text.len(string.rep(" ", left_highlight_padding))
  row_text = row_text .. left_padding .. keycap
  local end_col = Text.len(row_text) + Text.len(string.rep(" ", right_highlight_padding))
  row_text = row_text .. left_padding .. keycap .. right_padding
  return Text.get_key_highlight_position(row_text, start_col, end_col)
end

-- generate a string representation of the layout, e.g.
-- ┌──────┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬──────┐
-- │  `   │1│2│3│4│5│6│7│8│9│0│-│=│ <BS> │
-- ├──────┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼──────┤
-- │<TAB> │q│w│e│r│t│y│u│i│o│p│[│]│  \   │
-- ├──────┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┴──────┤
-- │<CAPS>│a│s│d│f│g│h│j│k│l│;│'│ <ENTER>│
-- ├──────┴─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼────────┤
-- │<LSHIFT>│z│x│c│v│b│n│m│,│.│/│<RSHIFT>│
-- └────────┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴────────┘
--  ┌───────┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬──────┐
--  │   `   │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │ 7 │ 8 │ 9 │ 0 │ - │ = │ <BS> │
--  ├───────┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼──────┤
--  │ <TAB> │ q │ w │ e │ r │ t │ y │ u │ i │ o │ p │ [ │ ] │   \  │
--  ├───────┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴──────┤
--  │ <CAPS> │ a │ s │ d │ f │ g │ h │ j │ k │ l │ ; │ ' │ <ENTER> │
--  ├────────┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴─────────┤
--  │ <LSHIFT>  │ z │ x │ c │ v │ b │ n │ m │ , │ . │ / │ <RSHIFT> │
--  └───────────┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴──────────┘
--  Need to represent:
--    * Ctrl + <key>
--    * Shift + <key>
function Layout:calculate_layout()
  -- I really want to refactor this
  -- This code is so ugly
  local row_sizes = {}
  row_sizes[1] = 14
  row_sizes[2] = 14
  row_sizes[3] = 13
  row_sizes[4] = 12
  row_sizes[5] = 9
  local rows = {}
  local keycap_separator_columns = {}
  keycap_separator_columns[1] = {}
  keycap_separator_columns[2] = {}
  keycap_separator_columns[3] = {}
  keycap_separator_columns[4] = {}
  keycap_separator_columns[5] = {}
  local row_lengths = {}

  local keys_in_layout = Keycaps[self.keycap_layout]

  -- prepare a table to hold the keycaps
  local key_strings = {}
  -- keep track of the column within each row for the keycap
  local column_index = 1
  -- keep track of the row on the keyboard display
  local row_index = 1
  -- keep track of the longest row
  local longest_row_length = 0

  -- captures how many spaces to put around labels
  local padding = self.options.key_labels.padding
  -- captures how much highlighting to put around labels
  local highlight_padding = self.options.key_labels.highlight_padding
  -- place keys in rows
  for i = 1, #keys_in_layout do
    local keycap = keys_in_layout[i][2]
    if self.options.key_labels[keycap] then
      keycap = self.options.key_labels[keycap]
    end
    local keycap_entry = keycap
    local left_pad = strrep(" ", padding[2])
    local right_pad = strrep(" ", padding[4])
    keycap = left_pad .. keycap .. right_pad
    -- store the keycap label
    key_strings[column_index] = keycap
    -- this is more efficient than using `table.insert`
    column_index = column_index + 1
    local row_len = row_lengths[row_index] or 0
    -- add 1 for counting the separator
    row_lengths[row_index] = row_len + Text.len(keycap) + 1
    print("Add keycap entry for " .. keycap_entry)
    self.keycap_positions[keycap_entry] = {
      ["keycap"] = keycap_entry,
      ["left_pad"] = left_pad,
      ["right_pad"] = right_pad,
      -- output row = upper padding * rows above
      -- output row = output row + lower padding * rows above
      -- output row = output row + upper padding + rows of characters above + separator rows above
      -- output row = padding[1] * (i - 1) + padding[3] * (i - 1) + padding[1] + i + i
      -- output row = padding[1] * (i) + padding[3] * (i - 1) + i + i
      -- output row = padding[1] * (i) + padding[3] * (i) - padding[3] + i + i
      -- Need to subtract by one to account for the top row
      row = row_index + row_index + (padding[1] + padding[3]) * row_index - padding[3] - 1,
      -- TODO: Support highlighting above and below
    }
    longest_row_length = max(longest_row_length, row_lengths[row_index])
    if column_index > row_sizes[row_index] then
      -- restart the column and row index
      column_index = 1
      rows[row_index] = key_strings
      key_strings = {}
      row_index = row_index + 1
    end
  end
  -- store the last row
  rows[row_index] = key_strings

  -- resize first and last columns based on the longest row
  for i = 1, #rows - 1 do
    local end_column = row_sizes[i]
    local row_length_delta = longest_row_length - row_lengths[i]
    local start_column_pad = math.ceil(row_length_delta / 2)
    local end_column_pad = math.floor(row_length_delta / 2)
    local keycap, left_pad, right_pad = center(rows[i][1], Text.len(rows[i][1]) + start_column_pad, true)
    self.keycap_positions[vim.trim(keycap)]["left_pad"] = string.rep(" ", left_pad)
      .. self.keycap_positions[vim.trim(keycap)]["left_pad"]
    self.keycap_positions[vim.trim(keycap)]["right_pad"] = string.rep(" ", right_pad)
      .. self.keycap_positions[vim.trim(keycap)]["right_pad"]
    rows[i][1] = keycap
    keycap, left_pad, right_pad = center(rows[i][end_column], Text.len(rows[i][end_column]) + end_column_pad)
    self.keycap_positions[vim.trim(keycap)]["left_pad"] = string.rep(" ", left_pad)
      .. self.keycap_positions[vim.trim(keycap)]["left_pad"]
    self.keycap_positions[vim.trim(keycap)]["right_pad"] = string.rep(" ", right_pad)
      .. self.keycap_positions[vim.trim(keycap)]["right_pad"]
    rows[i][end_column] = keycap
  end

  -- resize space button
  do
    local row_length_delta = longest_row_length - row_lengths[5]
    local keycap, left_pad, right_pad = center(rows[5][4], Text.len(rows[5][4]) + row_length_delta)
    rows[5][4] = keycap
    self.keycap_positions[vim.trim(keycap)]["left_pad"] = string.rep(" ", left_pad)
      .. self.keycap_positions[vim.trim(keycap)]["left_pad"]
    self.keycap_positions[vim.trim(keycap)]["right_pad"] = string.rep(" ", right_pad)
      .. self.keycap_positions[vim.trim(keycap)]["right_pad"]
  end

  -- calculate keycap separator locations
  for i = 1, #rows do
    local row = rows[i]
    local row_length = 0
    local row_text = ""
    for col = 1, #row do
      local keycap = row[col]
      local keycap_entry = vim.trim(keycap)
      local keycap_position =
        Layout.calculate_byte_position(row_text, self.keycap_positions[keycap_entry], highlight_padding)
      row_text = row_text .. charset["ss  "] .. keycap

      self.keycap_positions[keycap_entry]["from"] = keycap_position["from"]
      self.keycap_positions[keycap_entry]["to"] = keycap_position["to"]
      -- add the length of the separator
      row_length = row_length + Text.len(row[col]) + Text.len(charset["ss  "])
      -- mark where there is a separator
      keycap_separator_columns[i][row_length] = true
    end
  end

  -- place top row
  local top_row = { charset[" s s"] }
  for col = 1, #rows[1] do
    local row = rows[1]
    if Text.len(row[col]) > 0 then
      table.insert(top_row, strrep("─", Text.len(row[col])))
    end
    if col < #rows[1] then
      table.insert(top_row, charset[" sss"])
    else
      table.insert(top_row, charset[" ss "])
    end
  end
  self.text:set(1, table.concat(top_row))
  table.insert(self.layout, top_row)

  -- add lines between keys
  -- this part is weird because we're adding the border
  -- to the bottom right of each cell
  for i = 1, #rows do
    local row = rows[i]
    local separator_row = {}
    local pad_row = {}
    for pos = 1, longest_row_length do
      local up_line = (keycap_separator_columns[i] or {})[pos]
      local down_line = (keycap_separator_columns[i + 1] or {})[pos]
      local left_line = pos > 0
      local right_line = pos < longest_row_length

      -- insert a start character
      if pos == 1 then
        local line_opts = {
          (i > 0 and "s") or " ", -- up
          (i < #rows and "s") or " ", -- down
          (false and "s") or " ", -- left
          (right_line and "s") or " ", -- right
        }
        local char = get_line(line_opts)
        table.insert(separator_row, char)
        local pad_opts = {
          (i > 0 and "s") or " ", -- up
          (i <= #rows and "s") or " ", -- down
          " ", -- left
          " ", -- right
        }
        local pad_char = get_line(pad_opts)
        table.insert(pad_row, pad_char)
      end

      local line_opts = {
        (up_line and "s") or " ", -- up
        (down_line and "s") or " ", -- down
        (left_line and "s") or " ", -- left
        (right_line and "s") or " ", -- right
      }
      local char = get_line(line_opts)
      table.insert(separator_row, char)
      local pad_opts = {
        (up_line and "s") or " ", -- up
        (up_line and "s") or " ", -- down
        " ", -- left
        " ", -- right
      }
      local pad_char = get_line(pad_opts)
      table.insert(pad_row, pad_char)
    end
    -- add top padding
    for _ = 1, self.options.key_labels.padding[1] do
      self.text:append(table.concat(pad_row))
      table.insert(self.layout, pad_row)
    end
    self.text:append("│" .. table.concat(row, "│") .. "│")
    table.insert(self.layout, row)
    -- add bottom padding
    for _ = 1, self.options.key_labels.padding[3] do
      self.text:append(table.concat(pad_row))
      table.insert(self.layout, pad_row)
    end
    self.text:append(table.concat(separator_row, ""))
    table.insert(self.layout, separator_row)
  end

  return self.text
end

---Return keycap in a region
---@param row integer
---@param col integer
---@return string
function Layout:keycap_in_region(row, col)
  -- row is some number between 5 * top_padding + 5 + 5 * bottom_padding + #separator_rows
  -- for keycap, entry in pairs(self.keycap_positions) do
  --   print(keycap)
  --   print(entry)
  -- end
  return self.layout[row][col]
end

return Layout
