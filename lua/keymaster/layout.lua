local Config = require("keymaster.config")
local Text = require("keymaster.text")
local Keycaps = require("keymaster.keycaps")
-- this file generates the keyboard display
local strrep = string.rep
local max = math.max

local charset = {
  -- [ up down left right ] = char
  --      s : single
  [" s s"] = "┌",
  ["sss "] = "┤",
  [" ss "] = "┐",
  ["s  s"] = "└",
  ["s ss"] = "┴",
  [" sss"] = "┬",
  ["ss s"] = "├",
  ["  ss"] = "─",
  ["ssss"] = "┼",
  ["s s "] = "┘",
  ["ss  "] = "│",
}

local function get_line(opts)
  return charset[table.concat(opts, "")]
end

---@class Layout
---@field options Options
---@field text Text
---@field keycap_layout Keycaps
local Layout = {}
Layout.__index = Layout

---@param options? Options
function Layout:new(options)
  options = options or Config.options
  local this = {
    options = options,
    text = Text:new(),
    keycap_layout = options.layout or Config.options.layout,
  }
  setmetatable(this, self)
  return this
end

local function center(str, width, shift_left)
  local total_padding = width - Text.len(str)
  local small_pad = math.floor(total_padding / 2)
  local big_pad = math.ceil(total_padding / 2)
  if shift_left then
    return strrep(" ", small_pad) .. str .. strrep(" ", big_pad)
  else
    return strrep(" ", big_pad) .. str .. strrep(" ", small_pad)
  end
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
function Layout:layout()
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
  -- place keys in rows
  for i = 1, #keys_in_layout do
    local keycap = keys_in_layout[i][2]
    local left_pad = strrep(" ", Config.options.key_labels.padding[2])
    local right_pad = strrep(" ", Config.options.key_labels.padding[4])
    keycap = left_pad .. keycap .. right_pad
    -- store the keycap label
    key_strings[column_index] = keycap
    -- this is more efficient than using `table.insert`
    column_index = column_index + 1
    local row_len = row_lengths[row_index] or 0
    -- add 1 for counting the separator
    row_lengths[row_index] = row_len + Text.len(keycap) + 1
    longest_row_length = max(longest_row_length, row_lengths[row_index])
    if column_index > row_sizes[row_index] then
      -- restart the column and row index
      column_index = 1
      rows[row_index] = key_strings
      key_strings = {}
      row_index = row_index + 1
    end
  end

  -- resize first and last columns based on the longest row
  for i = 1, #rows do
    local end_column = row_sizes[i]
    local row_length_delta = longest_row_length - row_lengths[i]
    local start_column_pad = math.ceil(row_length_delta / 2)
    local end_column_pad = math.floor(row_length_delta / 2)
    rows[i][1] = center(rows[i][1], Text.len(rows[i][1]) + start_column_pad, true)
    rows[i][end_column] = center(rows[i][end_column], Text.len(rows[i][end_column]) + end_column_pad)
  end

  -- calculate keycap separator locations
  for i = 1, #rows do
    local row = rows[i]
    local row_length = 0
    for col = 1, #row do
      local keycap = row[col]
      -- add the length of the separator
      row_length = row_length + Text.len(keycap) + 1
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

  -- add lines around keys
  -- this part is weird because we're adding the border
  -- to the bottom right of each cell
  for i = 1, #rows do
    local row = rows[i]
    local new_row = {}
    for pos = 1, longest_row_length do
      local up_line = (keycap_separator_columns[i] or {})[pos]
      local down_line = (keycap_separator_columns[i + 1] or {})[pos]
      local left_line = pos > 0
      local right_line = pos < longest_row_length

      if pos == 1 then
        local line_opts = {
          (i > 0 and "s") or " ", -- up
          (i < #rows and "s") or " ", -- down
          (false and "s") or " ", -- left
          (right_line and "s") or " ", -- right
        }
        local char = get_line(line_opts)
        table.insert(new_row, char)
      end
      local line_opts = {
        (up_line and "s") or " ", -- up
        (down_line and "s") or " ", -- down
        (left_line and "s") or " ", -- left
        (right_line and "s") or " ", -- right
      }
      local char = get_line(line_opts)
      table.insert(new_row, char)
    end
    self.text:append("│" .. table.concat(row, "│") .. "│")
    self.text:append(table.concat(new_row, ""))
  end

  return self.text
end

--[[ local test_layout = Layout:new({layout="dvorak"}) ]]
--[[ print(table.concat(test_layout:layout().lines, "\n")) ]]
return Layout
