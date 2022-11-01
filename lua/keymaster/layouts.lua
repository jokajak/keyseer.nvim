local strlen = string.len
local strrep = string.rep

local M = {}

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

local qwerty_keys = {
  [1] = { "`", "`"},
  [2] = { "1", "1"},
  [3] = { "2", "2"},
  [4] = { "3", "3"},
  [5] = { "4", "4"},
  [6] = { "5", "5"},
  [7] = { "6", "6"},
  [8] = { "7", "7"},
  [9] = { "8", "8"},
  [10] = { "9", "9"},
  [11] = { "0", "0"},
  [12] = { "-", "-"},
  [13] = { "=", "="},
  [14] = { "<BS>", "<BS>"},
  [15] = { "<TAB>", "<TAB>"},
  [16] = { "q", "q"},
  [17] = { "w", "w"},
  [18] = { "e", "e"},
  [19] = { "r", "r"},
  [20] = { "t", "t"},
  [21] = { "y", "y"},
  [22] = { "u", "u"},
  [23] = { "i", "i"},
  [24] = { "o", "o"},
  [25] = { "p", "p"},
  [26] = { "[", "["},
  [27] = { "]", "]"},
  [28] = { "\\", "\\"},
  [29] = { "<CAPS>", "<CAPS>"},
  [30] = { "a", "a"},
  [31] = { "s", "s"},
  [32] = { "d", "d"},
  [33] = { "f", "f"},
  [34] = { "g", "g"},
  [35] = { "h", "h"},
  [36] = { "j", "j"},
  [37] = { "k", "k"},
  [38] = { "l", "l"},
  [39] = { ";", ";"},
  [40] = { "'", "'"},
  [41] = { "<ENTER>", "<ENTER>"},
  [42] = { "<LSHIFT>", "<LSHIFT>"},
  [43] = { "z", "z"},
  [44] = { "x", "x"},
  [45] = { "c", "c"},
  [46] = { "v", "v"},
  [47] = { "b", "b"},
  [48] = { "n", "n"},
  [49] = { "m", "m"},
  [50] = { ",", ","},
  [51] = { ".", "."},
  [52] = { "/", "/"},
  [53] = { "<RSHIFT>", "<RSHIFT>"},
}

local dvorak_keys = {
  [1] = { "`", "`"},
  [2] = { "1", "1"},
  [3] = { "2", "2"},
  [4] = { "3", "3"},
  [5] = { "4", "4"},
  [6] = { "5", "5"},
  [7] = { "6", "6"},
  [8] = { "7", "7"},
  [9] = { "8", "8"},
  [10] = { "9", "9"},
  [11] = { "0", "0"},
  [12] = { "-", "["},
  [13] = { "=", "]"},
  [14] = { "<BS>", "<BS>"},
  [15] = { "<TAB>", "<TAB>"},
  [16] = { "q", "'"},
  [17] = { "w", ","},
  [18] = { "e", "."},
  [19] = { "r", "p"},
  [20] = { "t", "y"},
  [21] = { "y", "f"},
  [22] = { "u", "g"},
  [23] = { "i", "c"},
  [24] = { "o", "r"},
  [25] = { "p", "l"},
  [26] = { "[", "/"},
  [27] = { "]", "="},
  [28] = { "\\", "\\"},
  [29] = { "<CAPS>", "<CAPS>"},
  [30] = { "a", "a"},
  [31] = { "s", "o"},
  [32] = { "d", "e"},
  [33] = { "f", "u"},
  [34] = { "g", "i"},
  [35] = { "h", "d"},
  [36] = { "j", "h"},
  [37] = { "k", "t"},
  [38] = { "l", "n"},
  [39] = { ";", "s"},
  [40] = { "'", "-"},
  [41] = { "<ENTER>", "<ENTER>"},
  [42] = { "<LSHIFT>", "<LSHIFT>"},
  [43] = { "z", ";"},
  [44] = { "x", "q"},
  [45] = { "c", "j"},
  [46] = { "v", "k"},
  [47] = { "b", "x"},
  [48] = { "n", "b"},
  [49] = { "m", "m"},
  [50] = { ",", "w"},
  [51] = { ".", "v"},
  [52] = { "/", "z"},
  [53] = { "<RSHIFT>", "<RSHIFT>"},
}

-- list of supported layouts
--[[ M.layouts = {
    "qwerty" = qwerty_keys,
    "dvorak" = dvorak_keys
} ]]

local function center(str, width, shift_left)
  local small_shift = math.floor(width / 2) - math.floor(strlen(str) / 2)
  local big_shift = math.floor(width / 2) - math.ceil(strlen(str) / 2)
  if shift_left then
    return strrep(' ', small_shift) .. str .. strrep(' ', big_shift)
  else
    return strrep(' ', big_shift) .. str .. strrep(' ', small_shift)
  end
end

local function stringify_row(row)
  -- must use ascii | instead of unicode separator
  -- so that strlen works
  return table.concat(row, "|")
end

local function stringify_row_at_col(row, col)
  local t = {}
  for i=1, #row do
    if i <= col then
      t[i] = row[i]
    end
  end
  return stringify_row(t)
end

-- generate a strrepresentation of the layout, e.g.
-- ┌──────┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬──────┐
-- │  `   │1│2│3│4│5│6│7│8│9│0│-│=│ <BS> │
-- ├──────┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼──────┤
-- │<TAB> │q│w│e│r│t│y│u│i│o│p│[│]│  \   │
-- ├──────┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┴──────┤
-- │<CAPS>│a│s│d│f│g│h│j│k│l│;│'│ <ENTER>│
-- ├──────┴─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼────────┤
-- │<LSHIFT>│z│x│c│v│b│n│m│,│.│/│<RSHIFT>│
-- └────────┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴────────┘
function M.render(layout)
  local row_sizes = {}
  row_sizes[1] = 14
  row_sizes[2] = 14
  row_sizes[3] = 13
  row_sizes[4] = 12
  row_sizes[5] = 9
  local rows = {}
  local longest_row = 0
  local column_sizes = {0}

  -- place pipes around each of the keys
  local key_strings = {}
  local table_index = 1
  local row_index = 1
  -- place keys in rows
  for i=1, #layout do
    key_strings[table_index] = layout[i][2]
    table_index = table_index + 1
    if (table_index) > row_sizes[row_index] then
      table_index = 1
      rows[row_index] = key_strings
      key_strings = {""}
      row_index = row_index + 1
    end
  end

  -- determine column sizes
  for i=1, #rows do  -- for each row
    local row = rows[i]  -- get a local reference
    local current_row_size = #row
    local prev_row_size = #(rows[i-1] or {})
    local offsets = 0
    for col=1, #row do  -- for each column in the row
      local current_column_size = strlen(row[col])  -- get the current column size
      -- check if the prev row is bigger than the current row
      -- if it is, then assume we need to compare the size of the previous row column
      -- directly above and next to the current column
      -- if they are the same or smaller then we combine them and don't resize the column
      -- X Y
      -- C
      if current_row_size < prev_row_size then
        local char_north = strlen(rows[i-1][col])
        local char_northeast = strlen(rows[i-1][col+1])
        local size_above = char_north + char_northeast + 1  -- add space for a separator
        if size_above > current_column_size then -- resize the current column
          column_sizes[col+offsets] = math.max((column_sizes[col] or 0), current_column_size)
        else
          offsets = offsets + 1
        end
      else
        -- if they are the same size, then just compare to the rest of the rows
        column_sizes[col] = math.max((column_sizes[col] or 0), current_column_size)
      end
    end
  end
  -- calculate the longest row
  for i=1, #rows do
    longest_row = math.max(longest_row, strlen(table.concat(rows[i])))
  end
  -- fixup the last column in the long rows
  local col = 14
  -- remove extra separators
  column_sizes[col] = longest_row - strlen(table.concat(rows[1])) - 2

  -- resize columns in each row
  for i=1, #rows do  -- for each row
    local row = rows[i]  -- get a local reference
    for col=1, #row do
      if not (#row == 14 and col > 12) then
        row[col] = center(row[col], column_sizes[col] or strlen(row[col]))
      elseif (#row == 14 and col > 13) then
        row[col] = center(row[col], column_sizes[col] or strlen(row[col]))
      end
    end
  end

  local final_rows = {}
  local top_row = {charset[" s s"]}
  for col=1, #rows[1] do
    local row = rows[1]
    if strlen(row[col]) > 0 then
      table.insert(top_row, strrep("─", strlen(row[col])))
    end
    if col < #rows[1] then
      table.insert(top_row, charset[" sss"])
    else
      table.insert(top_row, charset[" ss "])
    end
  end
  table.insert(final_rows, table.concat(top_row))

  -- add lines around keys
  -- this part is weird because we're adding the border
  -- to the bottom right of each cell
  for i=1, #rows do
    local row = rows[i]
    local separators = {}
    local new_row = {}
    local offset = 0
    for col=1, #row do
      local down_line = false
      local left_line = col > 0
      local right_line = col < #row
      local current_len = strlen(stringify_row_at_col(row, col), row[col])
      if i < #rows then
        for next_row_col=1, #rows[i+1] do
          local next_row_len = strlen(stringify_row_at_col(rows[i+1], next_row_col))
          if current_len == next_row_len then
            down_line = true
          end
        end
      end
      local line_opts = {
        (i > 0 and "s") or " ",  -- up
        (down_line and "s") or " ",  -- down
        (left_line and "s") or " ",  -- left
        (right_line and "s") or " ",  -- right
      }
      local char = get_line(line_opts)
      if col == 1 then
        local line_opts = {
          (i > 0 and "s") or " ",
          (i < #rows and "s") or " ",
          (col > 1 and "s") or " ",
          (col < #row and "s") or " ",
        }
        first_char = get_line(line_opts)
        table.insert(new_row, first_char)
      end
      if strlen(row[col]) > 0 then
        table.insert(new_row, strrep("─", strlen(row[col])))
      end
      table.insert(new_row, char)
    end
    table.insert(final_rows, "│"..table.concat(row, "│").."│")
    table.insert(final_rows, table.concat(new_row, ""))
  end

  print(table.concat(final_rows, "\n"))
end

return M
