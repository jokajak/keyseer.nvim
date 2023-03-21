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

---@class Button
---@field keycap string The string printed on the button
---@field keycode string The neovim key
---@field left_pad number The number of spaces to the left of the keycap
---@field right_pad number The number of spaces to the right of the keycap
---@field row number The row of the string on the output
---@field top_row number The top row of the button in the output
---@field bottom_row number The bottom row of the button on the output
---@field left_col number The leftmost column of the button in the output
---@field right_col number The rightmost column of the button in the output
---@field highlight_box HighlightBox The highlight box for the button
---@field width number The width of the entire button
---@field private _keycap_width number The width of the keycap string
---@field private _highlights BoundingBox the highlight padding around the keycap
local Button = {}
Button.__index = Button

---@class HighlightBox
---@field start_col number The start column
---@field end_col number The end column
---@field start_row number The start row
---@field end_row number The end row

---@class PaddingBox
---@field left_pad number The number of spaces to the left of the keycap string
---@field right_pad number The number of spaces to the right of the keycap string
---@field top_pad number The number of blank lines above the keycap string
---@field bottom_pad number The number of blank lines below the keycap string

---@class BoundingBox
---@field left number The number of spaces to the left of the keycap string
---@field right number The number of spaces to the right of the keycap string
---@field top number The number of blank lines above the keycap string
---@field bottom number The number of blank lines below the keycap string

---Generate a new button object
---@param keycap string The string that gets rendered on screen
---@param keycode string The neovim key
---@param row_index number The row for the button
---@param padding_box PaddingBox the padding around the keycap
---@param highlight_box PaddingBox the highlight padding around the keycap
---@return Button
function Button:new(keycap, keycode, row_index, padding_box, highlight_box)
  local top_pad, left_pad, bottom_pad, right_pad = padding_box[1], padding_box[2], padding_box[3], padding_box[4]
  local hl_top, hl_left, hl_bottom, hl_right = highlight_box[1], highlight_box[2], highlight_box[3], highlight_box[4]

  -- let text_height = 1
  -- let separator_height = 1
  -- let height of button = top_pad + text_height + bottom_pad
  -- let row height = separator_height + height of button
  -- (each row shares a separator row with the one above it)
  --
  -- 1 |--------- <-- separator |
  -- 2 | top_pad                |
  -- 3 | keycap                 | row_index = 1
  -- 4 | bottom_pad             |
  -- 5 |--------- <-- separator |
  -- 6 | top_pad                |
  -- 7 | keycap                 | row_index = 2
  --
  -- row for keycap = (rows_above) * (top_pad + bottom_pad + keycap_height + separator_height) + top_pad
  -- row for keycap = (row_index - 1) * (top_pad + bottom_pad + 1 + 1) + top_pad
  -- row for keycap = (row_index) * (top_pad + bottom_pad + 2) - (top_pad + bottom_pad + 2) + tap_pad
  -- row for keycap = row_index * top_pad + row_index * bottom_pad + row_index * 2
  --                - top_pad - bottom_pad - 2 + top_pad
  -- row for keycap = row_index * top_pad + row_index * bottom_pad - bottom_pad + row_index * 2 - 2
  -- row for keycap = row_index + row_index + (top_pad + bottom_pad) * row_index - bottom_pad - 2
  --
  -- This math is confusing but appears to be correct
  --
  -- output row = upper padding * rows above
  -- output row = output row + lower padding * rows above
  -- output row = output row + upper padding + rows of characters above + separator rows above
  -- output row = padding[1] * (i - 1) + padding[3] * (i - 1) + padding[1] + i + i
  -- output row = padding[1] * (i) + padding[3] * (i - 1) + i + i
  -- output row = padding[1] * (i) + padding[3] * (i) - padding[3] + i + i
  -- Need to subtract by one to account for the top row
  local row = row_index + row_index + (top_pad + bottom_pad) * row_index - bottom_pad - 1
  local keycap_width = vim.fn.strwidth(keycap)
  local this = {
    keycap = keycap,
    keycode = keycode,
    left_pad = left_pad,
    right_pad = right_pad,
    row = row,
    top_row = row - top_pad,
    bottom_row = row + bottom_pad,
    width = left_pad + keycap_width + right_pad,
    _keycap_width = keycap_width,
    _highlights = {
      top = hl_top,
      bottom = hl_bottom,
      left = hl_left,
      right = hl_right,
    },
    left_byte_col = 0,
    right_byte_col = left_pad + keycap_width + right_pad,
  }
  setmetatable(this, self)
  return this
end

---Get string representation of a button
---@return string
function Button:__tostring()
  local left_pad = strrep(" ", self.left_pad)
  local right_pad = strrep(" ", self.right_pad)
  return left_pad .. self.keycap .. right_pad
end

---Add padding to a button
---@param padding number The amount of padding to add
function Button:add_padding(padding, shift_left)
  local total_padding = self.left_pad + self.right_pad + padding
  local small_pad = math.floor(total_padding / 2)
  local big_pad = math.ceil(total_padding / 2)
  if shift_left then
    self.left_pad = small_pad
    self.right_pad = big_pad
  else
    self.left_pad = big_pad
    self.right_pad = small_pad
  end
  self.width = small_pad + self._keycap_width + big_pad
end

---Get highlight details
---@return number start_col The start column for highlights
---@return number end_col The end column for highlights
---@return number start_row The start row for highlights
---@return number end_row The end row for highlights
function Button:get_highlights()
  local left_padding = self.left_pad
  local right_padding = self.right_pad
  -- |<left padding=26>         K<right padding=26>        |
  -- |<highlight padding left=1>K<hl padding right 1>      |
  -- col_start = 26 - 1
  -- calculate how many unhighlighted padding spaces there should be on the left
  -- no less than 0, calculated as removing left_highlight_padding from left_padding
  local start_col = math.max(0, left_padding - self._highlights.left)

  -- Calculate how many highlighted spaces there should be to the right
  -- minimum of the highlight padding to the right and the available padding
  local end_col = math.min(right_padding, self._highlights.right)

  local top_row = self.top_row
  local bottom_row = self.bottom_row
  local start_row = self.row - math.max(0, top_row - self._highlights.top)
  local end_row = self.row + math.min(bottom_row, self._highlights.bottom)
  return start_col, end_col, start_row, end_row
end

---Set button position in layout
---@param col number The column for the button to start
function Button:set_button_byte_position(col)
  -- strcharpart('abc', -1, 2)
  --            -1012
  --     start --^
  --       end ----^
  --       returns a
  -- based on strcharpart
  -- |  1  |
  -- 12345
  -- --^ = start col = 3
  -- ----^ = end col = 5
  -- would return 1 which is what we want
  -- right_col therefore = col + self._keycap_width + self.right_pad
  self.left_byte_col = col
  self.right_byte_col = col + self.width
end

---@class Layout
---@field options Options
---@field text Text
---@field layout string[]
---@field keycap_layout string[]
---@field buttons Button[] A table of Buttons for each keycode
---@field keycaps Keycap[]
---@field regions table[]
---@field private _text Text The string representation
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
    buttons = setmetatable({}, {
      -- Ensure every entry in keycap_positions is a table
      __index = function(tbl, key)
        local new_tbl = {}
        rawset(tbl, key, new_tbl)
        return new_tbl
      end,
    }),
    regions = {},
  }
  setmetatable(this, self)
  return this
end

---Get layout string
---@return string layout The string representation
function Layout:__tostring()
  if not self._text then
    self._text = self:calculate_layout()
  end
  return tostring(self._text)
end

---Get the start column and end column
---@param line string The string of characters to find byte positions
---@param from number The start column
---@param to number The end column
---@return number start_col the start column in bytes
---@return number end_col the end column in bytes
local function get_str_bytes(line, from, to)
  -- Because the separators are multi-byte strings,
  -- we have to do a conversion for highlighting purposes
  local before = vim.fn.strcharpart(line, 0, from)
  local str = vim.fn.strcharpart(line, 0, to)
  from = vim.fn.strlen(before)
  to = vim.fn.strlen(str)
  return from, to
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

  local separator_width = vim.fn.strwidth(charset["ss  "])
  -- prepare a table to hold the buttons for each row
  local row_buttons = {}
  -- keep track of the column within each row for the keycap
  local column_index = 1
  -- keep track of the row on the keyboard display
  local row_index = 1
  -- keep track of the longest row
  local longest_row_length = 0

  -- captures how many spaces to put around labels
  local padding = self.options.key_labels.padding
  -- place keys in rows
  for i = 1, #keys_in_layout do
    local keycode = keys_in_layout[i][2]
    local keycap = keycode
    if self.options.key_labels[keycode] then
      keycap = self.options.key_labels[keycode]
    end
    local button = Button:new(keycap, keycode, row_index, padding, self.options.key_labels.highlight_padding)
    table.insert(row_buttons, button)
    -- this is more efficient than using `table.insert`
    column_index = column_index + 1
    local row_len = row_lengths[row_index] or 0
    row_len = row_len + button.width + separator_width
    row_lengths[row_index] = row_len

    table.insert(self.buttons[keycode], button)
    longest_row_length = max(longest_row_length, row_len)
    if column_index > row_sizes[row_index] then
      -- restart the column and row index
      column_index = 1
      row_index = row_index + 1
      table.insert(rows, row_buttons)
      row_buttons = {}
    end
  end
  -- store the last row
  table.insert(rows, row_buttons)

  -- resize first and last columns based on the longest row
  -- bottom row is excluded because the space button gets the padding
  for i = 1, #rows - 1 do
    local end_column = row_sizes[i]
    local row_length_delta = longest_row_length - row_lengths[i]
    local start_column_pad = math.ceil(row_length_delta / 2)
    local end_column_pad = math.floor(row_length_delta / 2)
    local row_start_button = rows[i][1]
    local row_end_button = rows[i][end_column]

    row_start_button:add_padding(start_column_pad, true)
    row_end_button:add_padding(end_column_pad, false)
  end

  -- resize space button
  do
    local row_length_delta = longest_row_length - row_lengths[5]
    -- Get the <Space> button from the layout
    -- At this point there should be at least one
    local button = self.buttons["<SPACE>"][1]
    button:add_padding(row_length_delta)
  end

  -- calculate keycap separator locations
  for i = 1, #rows do
    local row = rows[i]
    local row_length = 0
    local row_text = charset["ss  "]
    for col = 1, #row do
      local button = row[col]
      row_text = row_text .. tostring(button) .. charset["ss  "]
      local start_col, _ = get_str_bytes(row_text, row_length + 1, row_length + button.width)
      button:set_button_byte_position(start_col)
      -- add the length of the separator
      row_length = row_length + button.width + separator_width
      -- mark where there is a separator
      keycap_separator_columns[i][row_length] = true
    end
  end

  -- place top row
  local top_row = { charset[" s s"] }
  for col = 1, #rows[1] do
    local row = rows[1]
    local button = row[col]
    if button.width > 0 then
      table.insert(top_row, strrep("─", button.width))
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
  for i, row in ipairs(rows) do
    local separator_row = {}
    local pad_row = {}
    -- insert a start character
    local line_opts = {
      (i > 0 and "s") or " ", -- up
      (i < #rows and "s") or " ", -- down
      (false and "s") or " ", -- left
      "s", -- right
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

    -- keycap_separator_columns assume there is no character to the left
    for pos = 1, longest_row_length do
      local up_line = (keycap_separator_columns[i] or {})[pos]
      local down_line = (keycap_separator_columns[i + 1] or {})[pos]
      local left_line = pos > 0
      local right_line = pos < longest_row_length

      line_opts = {
        (up_line and "s") or " ", -- up
        (down_line and "s") or " ", -- down
        (left_line and "s") or " ", -- left
        (right_line and "s") or " ", -- right
      }
      char = get_line(line_opts)
      table.insert(separator_row, char)
      pad_opts = {
        (up_line and "s") or " ", -- up
        (up_line and "s") or " ", -- down
        " ", -- left
        " ", -- right
      }
      pad_char = get_line(pad_opts)
      table.insert(pad_row, pad_char)
    end
    -- add top padding
    for _ = 1, self.options.key_labels.padding[1] do
      self.text:append(table.concat(pad_row))
      table.insert(self.layout, pad_row)
    end
    local _keycap_strings = {}
    for _, button in ipairs(row) do
      table.insert(_keycap_strings, tostring(button))
    end
    self.text:append("│" .. table.concat(_keycap_strings, "│") .. "│")
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
