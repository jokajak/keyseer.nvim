-- This file describes a button object that represents a key on a keyboard
-- The button object encapsulates the logic for displaying and highlighting a button
local strrep = string.rep

-- table of key codes that are modifiers
local modifiers = {
  ["<Caps>"] = true,
  ["<Shift>"] = true,
  ["<Ctrl>"] = true,
  ["<Meta>"] = true,
}

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
--
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
---@field is_modifier boolean Whether or not a button is a modifier
---@field resizable boolean Whether or not the button can be resized
---@field private _keycap_width number The width of the keycap string
---@field private _highlights BoundingBox the highlight padding around the keycap
---@field private _padding BoundingBox the display padding around the keycap
local Button = {}
Button.__index = Button

---Generate a new button object
---@param keycap string The string that gets rendered on screen
---@param keycode string The neovim key
---@param row_index number The row for the button
---@param padding_box PaddingBox the padding around the keycap
---@param highlight_box PaddingBox the highlight padding around the keycap
---@param resizable boolean whether or not the button is resizable
---@return Button
function Button:new(keycap, keycode, row_index, padding_box, highlight_box, resizable)
  local top_pad, left_pad, bottom_pad, right_pad =
    padding_box[1], padding_box[2], padding_box[3], padding_box[4]
  local hl_top, hl_left, hl_bottom, hl_right =
    highlight_box[1], highlight_box[2], highlight_box[3], highlight_box[4]

  -- let text_height = 1
  -- let separator_height = 1
  -- let height of button = top_pad + text_height + bottom_pad
  -- let row height = separator_height + height of button
  -- (each row shares a separator row with the one above it)
  --
  -- 0 |--------- <-- separator |
  -- 1 | top_pad                |
  -- 2 | keycap                 | row_index = 1
  -- 3 | bottom_pad             |
  -- 4 |--------- <-- separator |
  -- 5 | top_pad                |
  -- 6 | keycap2                | row_index = 2
  --
  -- row = (separator_height + top_pad + bottom_pad + key_height) * (row_index - 1) + (separator_height + top_pad)
  -- keycap1 = (1 + 1 + 1 + 1) * 0 + (1 + 1) = 2
  -- keycap2 = (1 + 1 + 1 + 1) * 1 + (1 + 1) = 4 + 2 = 6
  -- This math is confusing but appears to be correct
  local row = (top_pad + bottom_pad + 1 + 1) * (row_index - 1) + (1 + top_pad)
  local keycap_width = vim.fn.strwidth(keycap)
  local this = {
    keycap = keycap,
    keycode = keycode,
    left_pad = left_pad,
    right_pad = right_pad,
    top_row = row - top_pad,
    row = row,
    bottom_row = row + bottom_pad,
    width = left_pad + keycap_width + right_pad,
    is_modifier = modifiers[keycode] or false,
    _keycap_width = keycap_width,
    _highlights = {
      top = hl_top,
      bottom = hl_bottom,
      left = hl_left,
      right = hl_right,
    },
    _padding = {
      top = top_pad,
      bottom = bottom_pad,
      left = left_pad,
      right = right_pad,
    },
    left_byte_col = 0,
    right_byte_col = left_pad + keycap_width + right_pad,
    resizable = false or resizable,
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
---@param shift_left boolean Whether or not to add padding to the right
---@param center boolean Whether or not to add padding on both sides
---@param shift_right boolean Whether or not to add padding to the left
function Button:add_padding(padding, shift_left, center, shift_right)
  local total_padding = self.left_pad + self.right_pad + padding
  local small_pad = math.floor(total_padding / 2)
  local big_pad = math.ceil(total_padding / 2)
  center = center or true
  shift_left = shift_left or false
  shift_right = shift_right or false
  if center then
    if shift_left then
      self.left_pad = small_pad
      self.right_pad = big_pad
      self._padding.left = small_pad
      self._padding.right = big_pad
    else
      self.left_pad = big_pad
      self.right_pad = small_pad
      self._padding.left = big_pad
      self._padding.right = small_pad
    end
    self.width = small_pad + self._keycap_width + big_pad
  elseif shift_left then
    self.right_pad = total_padding
    self._padding.right = total_padding
    self.width = self._keycap_width + total_padding
  elseif shift_right then
    self.left_pad = total_padding
    self._padding.left = total_padding
    self.width = self._keycap_width + total_padding
  end
end

---Get highlight details
---@return number start_col The byte start column for highlights
---@return number end_col The byte end column for highlights
---@return number start_row The start row for highlights
---@return number end_row The end row for highlights
function Button:get_highlights()
  local left_padding = self._padding.left
  local right_padding = self._padding.right
  -- |<left padding=26>         K<right padding=26>        |
  -- |<highlight padding left=1>K<hl padding right 1>      |
  -- col_start = 26 - 1
  -- calculate how many unhighlighted padding spaces there should be on the left
  -- before = vim.fn.strcharpart(line, 0, left_pad + row_prefix)
  -- after = vim.fn.strcharpart(line, 0, row_prefix + left_pad + button._keycap_width)
  -- no less than 0, calculated as removing left_highlight_padding from left_padding
  local start_col = math.max(0, left_padding - self._highlights.left) + self.left_byte_col

  -- Calculate how many highlighted spaces there should be to the right
  -- minimum of the highlight padding to the right and the available padding
  -- end_col = self.left_byte_col + self._keycap_width + left_padding +
  -- local end_col = self.right_byte_col - math.min(right_padding, self._highlights.right)
  local highlight_right_cols = math.min(right_padding, self._highlights.right)
  local end_col = self.left_byte_col + left_padding + self._keycap_width + highlight_right_cols
  local col_end = self.right_byte_col - self._padding.right + highlight_right_cols
  if end_col ~= col_end then
    print("Math is hard.")
  end

  -- if someone makes highlight really big then the start row should be the top_row
  local start_row = self.row - math.min(self._padding.top, self._highlights.top)
  local end_row = self.row + math.min(self._padding.bottom, self._highlights.bottom)
  return start_col, col_end, start_row, end_row
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

---Set the start column for the button
---@param col integer The start column
function Button:set_button_start_col(col)
  self.left_col = col
  self.right_col = col + self.width
end

---Highlight a buffer
---@param bufnr buffer A buffer
---@param namespace number The namespace for the highlights
---@param highlight_group string The highlighting to apply to the button
---@param row_offset number The row offset in case there's something above the row (like a header)
function Button:highlight(bufnr, namespace, highlight_group, row_offset)
  local col_start, col_end, start_row, end_row = self:get_highlights()
  for row = start_row, end_row do
    vim.api.nvim_buf_add_highlight(
      bufnr,
      namespace,
      highlight_group,
      row + row_offset,
      col_start,
      col_end
    )
  end
end

return Button
