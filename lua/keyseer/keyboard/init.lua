-- This file describes a keyboard object that represents a keyboard
-- The keyboard object encapsulates the logic for generating a text representation of a keyboard
-- The class will be responsible for calculating a rectangular representation of a keyboard
-- A keyboard can be displayed as having shift held down or not
-- Each button on the keyboard can be highlighted
local Button = require("keyseer.keyboard.button")
local Utils = require("keyseer.utils")
local Config = require("keyseer").config
local D = require("keyseer.util.debug")

-- Border characters for buttons
local _borders = {
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
  return _borders[table.concat(opts, "")]
end

-- From https://hiphish.github.io/blog/2022/03/15/lua-metatables-for-neovim-plugin-settings/
local function make_mt(default)
  return {
    __index = function(t, k)
      local original = default[k]
      if type(original) ~= "table" then
        return original
      end
      rawset(t, k, {})
      setmetatable(t[k], make_mt(original))
    end,
    __newindex = function(t, k, v)
      rawset(t, k, v)
      if type(v) ~= "table" then
        return
      end
      setmetatable(v, make_mt(default[k]))
    end,
  }
end

local function default_table()
  return setmetatable({}, {
    -- ensure every entry in the table is a table
    __index = function(tbl, key)
      local new_tbl = {}
      rawset(tbl, key, new_tbl)
      return new_tbl
    end,
  })
end

---@class Keyboard
---@field padding PaddingBox The spacing around each button keycap
---@field highlight_padding PaddingBox The extra highlights around a keycap
---@field key_labels table Keycap replacements
---@field shift_pressed boolean Whether or not the shift button is pressed
---@field height number The number of rows in the rendered keyboard
---@field width number The number of columns in the rendered keyboard
---@field layout PhysicalLayout The layout for the keyboard
---@field private _normal_buttons Button[] A mapping table from keycode to button when shift is not pressed
---@field private _shifted_buttons Button[] A mapping table from keycode to button when shift is pressed
---@field private _normal_lines string[] The string representation of the keyboard without shift pressed
---@field private _shifted_lines string[] The string representation of the keyboard with shift pressed
---@field private _locations Button[] A table of buttons for their position
---@field private _rows table The table of rows
---@field private _keycap_separator_colomns table Where the keycap separators are
local Keyboard = {}
Keyboard.__index = Keyboard

---@class KeyboardDisplayOptions
---@field padding PaddingBox the spacing around each button keycap
---@field highlight_padding PaddingBox the extra highlights around a keycap
---@field key_labels string[] A mapping table to replace a keycap with another label when output
---@field layout? PhysicalLayout The layout of buttons on the keyboard

---@class PhysicalKey
---@field normal string The keycode when no shift is pressed
---@field shifted string The keycode when shift is pressed
---@field resizable boolean? Whether or not the key should grow as neede

---@alias PhysicalKeyRow PhysicalKey[]
---@alias PhysicalLayout PhysicalKeyRow[]

---@class KeyboardRow
---@field buttons table[Button] The buttons on the row
---@field justification string How to pad buttons on the row
---@field length integer The display length of the row

---Create a new keyboard object
---@param options? KeyboardDisplayOptions
---@return Keyboard
function Keyboard:new(options)
  options = vim.tbl_deep_extend("force", {}, Config.keyboard, options or {})
  local this = {
    shift_pressed = false,
    _normal_buttons = default_table(),
    _shifted_buttons = default_table(),
    padding = options.keycap_padding,
    highlight_padding = options.highlight_padding,
    key_labels = options.key_labels,
  }
  if options.layout and type(options.layout) == "table" then
    this.layout = options.layout
  end
  setmetatable(this, self)
  self.__index = self
  return this
end

---Get lines
---@param shift_pressed boolean Whether or not to return the shifted lines
---@return string[] The string representation of the keyboard
function Keyboard:get_lines(shift_pressed)
  if not self._rows then
    self:_layout_buttons(shift_pressed)
  end

  if not shift_pressed then
    self._normal_lines = self._normal_lines or self:lines()
    return self._normal_lines
  else
    self._shifted_lines = self._shifted_lines or self:lines()
    return self._shifted_lines
  end
end

---Generate string representation
---@return string The string representation of the keyboard
function Keyboard:__tostring()
  return tostring(self:get_lines(self.shift_pressed))
end

---Resize the buttons in a row
---@param row KeyboardRow A table of buttons
---@return nil
function Keyboard:_resize_row(row, target_length)
  local row_length_delta = target_length - row.length
  if row_length_delta == 0 then
    -- nothing to resize, move on
    return
  end
  local resizable_indexes = {}
  for idx, button in ipairs(row) do
    if button.resizable then
      table.insert(resizable_indexes, row[idx])
    end
  end
  if #resizable_indexes == 0 then
    -- resize first and last columns based on the longest row
    -- because there are no resizable buttons in the row
    local end_column = #row
    local start_column_pad = math.ceil(row_length_delta / 2)
    local end_column_pad = math.floor(row_length_delta / 2)
    local row_start_button = row[1]
    local row_end_button = row[end_column]

    row_start_button:add_padding(start_column_pad, true)
    row_end_button:add_padding(end_column_pad, false)
  elseif #resizable_indexes == 1 then
    resizable_indexes[1]:add_padding(row_length_delta)
  else
    -- first, calculate the total padding available for each button:
    local padding_per_button = math.floor(row_length_delta / #resizable_indexes)
    local extra_padding = row_length_delta - (padding_per_button * #resizable_indexes)
    -- if row justification is left, then we pad from the right
    -- if row justification is center, then we pad from the middle
    -- if row justification is right, then we pad from the left
    -- if row justification is split, then we pad left and right with the extra
    D.tprint(resizable_indexes)
    for idx, button in pairs(resizable_indexes) do
      D.log("Keyboard", "Resize %s", button)
      button:add_padding(padding_per_button)
    end
    if row["justification"] == "split" then
      resizable_indexes[1]:add_padding(math.floor(extra_padding / 2))
      resizable_indexes[#resizable_indexes]:add_padding(math.ceil(extra_padding / 2))
    elseif row["justification"] == "left" then
      resizable_indexes[#resizable_indexes]:add_padding(extra_padding)
    elseif row["justification"] == "right" then
      resizable_indexes[1]:add_padding(extra_padding)
    elseif row["justification"] == "center" then
      local mid_index = math.floor(#resizable_indexes / 2)
      if #resizable_indexes % 2 == 0 then
        -- even number, split padding between two center elements
        resizable_indexes[mid_index]:add_padding(math.floor(extra_padding / 2))
        resizable_indexes[mid_index + 1]:add_padding(math.ceil(extra_padding / 2))
      else
        resizable_indexes[mid_index + 1]:add_padding(math.floor(extra_padding / 2))
      end
    else
      Utils.error("Unknown row justification provided")
    end
  end
  -- end
end

---Calculate the keyboard laout
---@param shift_pressed boolean Whether or not the shift button is held down
function Keyboard:_layout_buttons(shift_pressed)
  -- generate a string representation of the layout, e.g.
  -- ┌──────┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬──────┐
  -- │  `   │1│2│3│4│5│6│7│8│9│0│-│=│ <BS> │
  -- ├──────┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼──────┤
  -- │<TAB> │q│w│e│r│t│y│u│i│o│p│[│]│  \   │
  -- ├──────┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┴──────┤
  -- │<CAPS>│a│s│d│f│g│h│j│k│l│;│'│ <ENTER>│
  -- ├──────┴─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼────────┤
  -- │<SHIFT> │z│x│c│v│b│n│m│,│.│/│ <SHIFT>│
  -- └────────┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴────────┘
  --  ┌───────┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬──────┐
  --  │   `   │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │ 7 │ 8 │ 9 │ 0 │ - │ = │ <BS> │
  --  ├───────┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼──────┤
  --  │ <TAB> │ q │ w │ e │ r │ t │ y │ u │ i │ o │ p │ [ │ ] │   \  │
  --  ├───────┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴──────┤
  --  │ <CAPS> │ a │ s │ d │ f │ g │ h │ j │ k │ l │ ; │ ' │ <ENTER> │
  --  ├────────┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─────────┤
  --  │ <SHIFT>  │ z │ x │ c │ v │ b │ n │ m │ , │ . │ / │  <SHIFT>  │
  --  └──────────┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───────────┘
  -- Reset button mapping tables
  if shift_pressed then
    self._normal_buttons = default_table()
  else
    self._shifted_buttons = default_table()
  end
  local button_lookup = self._normal_buttons
  self._locations = button_lookup
  if shift_pressed then
    button_lookup = self._shifted_buttons
  end

  self._rows = {}
  self._keycap_separator_colomns = {}
  local rows = self._rows

  local keycap_separator_columns = self._keycap_separator_colomns

  -- convenience variable for the width of a separator character
  local separator_width = vim.fn.strwidth(_borders["ss  "])
  -- keep track of the longest row
  local longest_row_length = 0
  -- captures how many spaces to put around labels
  local padding = self.padding
  local highlight_padding = self.highlight_padding

  -- convert each row of PhysicalLayout of keycodes into rows of buttons
  for row_index, key_entries in ipairs(self.layout) do
    local buttons = {}
    local row_len = 0
    for _, key_entry in ipairs(key_entries) do
      local keycode = key_entry[shift_pressed and "shifted" or "normal"]
      local keycap = self.key_labels[keycode] or keycode
      local button = Button:new(
        keycap,
        keycode,
        row_index,
        padding,
        highlight_padding,
        key_entry["resizable"] or false,
        key_entry["width"] or 0
      )
      table.insert(buttons, button)
      row_len = row_len + button.width + separator_width

      table.insert(button_lookup[keycode], button)
    end
    rows[row_index] = buttons
    longest_row_length = math.max(longest_row_length, row_len)
    rows[row_index].length = row_len
    rows[row_index].justification = key_entries["alignment"] or "split"
  end

  -- resize first and last columns based on the longest row
  -- bottom row is excluded because the space button gets the padding
  for i = 1, #rows do
    self:_resize_row(rows[i], longest_row_length)
  end

  -- calculate keycap separator locations
  for row_index, row in ipairs(rows) do
    local row_length = 0
    local row_text = _borders["ss  "]
    keycap_separator_columns[row_index] = {}
    for _, button in ipairs(row) do
      button:set_button_start_col(row_length + 1)
      row_text = row_text .. tostring(button) .. _borders["ss  "]
      local start_col, _ = Utils.get_str_bytes(row_text, row_length + 1, row_length + button.width)
      button:set_button_byte_position(start_col)
      -- add the length of the separator
      row_length = row_length + button.width + separator_width
      -- mark where there is a separator
      keycap_separator_columns[row_index][row_length] = true
    end
  end
  self.width = longest_row_length
  self.height = #rows + #rows + 1
end

---convert keyboard to a table of strings
---@return string[] ret string representation of the keyboard
function Keyboard:lines()
  local ret = {}
  local rows = self._rows
  local keycap_separator_columns = self._keycap_separator_colomns
  local padding = self.padding

  local longest_row_length = 0

  for _, row in ipairs(rows) do
    longest_row_length = math.max(longest_row_length, row.length)
  end

  -- place top row
  local top_row = { _borders[" s s"] }
  for col, button in ipairs(rows[1]) do
    if button.width > 0 then
      table.insert(top_row, string.rep("─", button.width))
    end
    if col < #rows[1] then
      table.insert(top_row, _borders[" sss"])
    else
      table.insert(top_row, _borders[" ss "])
    end
  end
  table.insert(ret, table.concat(top_row))

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
    for _ = 1, padding[1] do
      table.insert(ret, table.concat(pad_row))
    end
    local _keycap_strings = {}
    for _, button in ipairs(row) do
      table.insert(_keycap_strings, tostring(button))
    end
    local sep = _borders["ss  "]
    table.insert(ret, sep .. table.concat(_keycap_strings, sep) .. sep)
    -- add bottom padding
    for _ = 1, padding[3] do
      table.insert(ret, table.concat(pad_row))
    end
    table.insert(ret, table.concat(separator_row, ""))
  end

  -- save the width. Every entry in ret should be the same length
  self.width = 0
  for _, v in ipairs(ret) do
    self.width = math.max(self.width, vim.fn.strdisplaywidth(v, 0))
  end

  return ret
end

---Return button at coordinates
---@param row integer
---@param col integer
---@return Button ret the button at the position
function Keyboard:get_keycap_at_position(row, col)
  -- We need to convert the row to a row index
  -- Each row is keycap_height + top_padding + bottom_padding tall
  -- We need to convert the col to a column index
  -- Converting a column back to a column index is hard because the buttons are different width
  ---@type Button
  local ret = nil
  for _, keycaps in pairs(self._locations) do
    for _, button in pairs(keycaps) do
      if button.top_row <= row and button.bottom_row >= row then
        if button.left_col < col and button.right_col >= col then
          if not ret then
            ret = button
          else
            Utils.notify("Found multiple matching buttons!")
          end
        end
      end
    end
  end
  return ret
end

---Populate lines in a display
---@param ui KeySeerUI The UI to display to
---@param keycaps KeyMapTreeNode The keycaps to display
---@return number height The height of the window
---@return number width The width of the window
function Keyboard:populate_lines(ui, keycaps)
  local display = ui.render
  local shift_pressed = ui.state.modifiers["<Shift>"]
  self:_layout_buttons(shift_pressed)

  local rows = self._rows
  local keycap_separator_columns = self._keycap_separator_colomns
  local padding = self.padding

  local longest_row_length = 0

  for _, row in ipairs(rows) do
    longest_row_length = math.max(longest_row_length, row.length)
  end

  -- place top row
  display:append(_borders[" s s"])
  for col, button in ipairs(rows[1]) do
    if button.width > 0 then
      display:append(string.rep("─", button.width))
    end
    if col < #rows[1] then
      display:append(_borders[" sss"])
    else
      display:append(_borders[" ss "])
    end
  end
  display:nl()

  -- for each row of buttons
  for row_index, row in ipairs(rows) do
    -- add the padding row above the keycap text
    for _ = 1, padding[1] do
      display:append(_borders["ss  "])
      -- for each button in the row
      for _, button in ipairs(row) do
        display:append(string.rep(" ", button.width))
        display:append(_borders["ss  "])
      end
      display:nl()
    end
    -- add the keycap text
    for _, button in ipairs(row) do
      display:append(_borders["ss  "]):append(tostring(button), keycaps[button.keycode])
    end
    display:append(_borders["ss  "]):nl()
    -- add the padding row below the keycap text
    for _ = 1, padding[3] do
      display:append(_borders["ss  "])
      -- for each button in the row
      for _, button in ipairs(row) do
        display:append(string.rep(" ", button.width))
        display:append(_borders["ss  "])
      end
      display:nl()
    end
    -- add lines below the current row of keycaps
    -- keycap_separator_columns assume there is no character to the left
    local first_char_in_separator_row = {
      (row_index > 0 and "s") or " ", -- up
      (row_index < #rows and "s") or " ", -- down
      " ", -- left
      "s", -- right
    }
    display:append(_borders[table.concat(first_char_in_separator_row, "")])
    for pos = 1, longest_row_length do
      local up_line = (keycap_separator_columns[row_index] or {})[pos]
      local down_line = (keycap_separator_columns[row_index + 1] or {})[pos]
      local left_line = pos > 0
      local right_line = pos < longest_row_length

      local line_opts = {
        (up_line and "s") or " ", -- up
        (down_line and "s") or " ", -- down
        (left_line and "s") or " ", -- left
        (right_line and "s") or " ", -- right
      }
      display:append(_borders[table.concat(line_opts, "")])
    end
    display:nl()
  end
  return display:row(), display:col()
end
return Keyboard
