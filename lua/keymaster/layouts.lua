local strlen = string.len
local strrep = string.rep
local strformat = string.format
local max = math.max

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

local Layout = {}

function Layout:new()
	local newObj = { row_length = 0 }
	self.__index = self
	return setmetatable(newObj, self)
end

local qwerty_keys = {
	[1] = { "`", "`" },
	[2] = { "1", "1" },
	[3] = { "2", "2" },
	[4] = { "3", "3" },
	[5] = { "4", "4" },
	[6] = { "5", "5" },
	[7] = { "6", "6" },
	[8] = { "7", "7" },
	[9] = { "8", "8" },
	[10] = { "9", "9" },
	[11] = { "0", "0" },
	[12] = { "-", "-" },
	[13] = { "=", "=" },
	[14] = { "<BS>", "<BS>" },
	[15] = { "<TAB>", "<TAB>" },
	[16] = { "q", "q" },
	[17] = { "w", "w" },
	[18] = { "e", "e" },
	[19] = { "r", "r" },
	[20] = { "t", "t" },
	[21] = { "y", "y" },
	[22] = { "u", "u" },
	[23] = { "i", "i" },
	[24] = { "o", "o" },
	[25] = { "p", "p" },
	[26] = { "[", "[" },
	[27] = { "]", "]" },
	[28] = { "\\", "\\" },
	[29] = { "<CAPS>", "<CAPS>" },
	[30] = { "a", "a" },
	[31] = { "s", "s" },
	[32] = { "d", "d" },
	[33] = { "f", "f" },
	[34] = { "g", "g" },
	[35] = { "h", "h" },
	[36] = { "j", "j" },
	[37] = { "k", "k" },
	[38] = { "l", "l" },
	[39] = { ";", ";" },
	[40] = { "'", "'" },
	[41] = { "<ENTER>", "<ENTER>" },
	[42] = { "<LSHIFT>", "<LSHIFT>" },
	[43] = { "z", "z" },
	[44] = { "x", "x" },
	[45] = { "c", "c" },
	[46] = { "v", "v" },
	[47] = { "b", "b" },
	[48] = { "n", "n" },
	[49] = { "m", "m" },
	[50] = { ",", "," },
	[51] = { ".", "." },
	[52] = { "/", "/" },
	[53] = { "<RSHIFT>", "<RSHIFT>" },
}

local dvorak_keys = {
	[1] = { "`", "`" },
	[2] = { "1", "1" },
	[3] = { "2", "2" },
	[4] = { "3", "3" },
	[5] = { "4", "4" },
	[6] = { "5", "5" },
	[7] = { "6", "6" },
	[8] = { "7", "7" },
	[9] = { "8", "8" },
	[10] = { "9", "9" },
	[11] = { "0", "0" },
	[12] = { "-", "[" },
	[13] = { "=", "]" },
	[14] = { "<BS>", "<BS>" },
	[15] = { "<TAB>", "<TAB>" },
	[16] = { "q", "'" },
	[17] = { "w", "," },
	[18] = { "e", "." },
	[19] = { "r", "p" },
	[20] = { "t", "y" },
	[21] = { "y", "f" },
	[22] = { "u", "g" },
	[23] = { "i", "c" },
	[24] = { "o", "r" },
	[25] = { "p", "l" },
	[26] = { "[", "/" },
	[27] = { "]", "=" },
	[28] = { "\\", "\\" },
	[29] = { "<CAPS>", "<CAPS>" },
	[30] = { "a", "a" },
	[31] = { "s", "o" },
	[32] = { "d", "e" },
	[33] = { "f", "u" },
	[34] = { "g", "i" },
	[35] = { "h", "d" },
	[36] = { "j", "h" },
	[37] = { "k", "t" },
	[38] = { "l", "n" },
	[39] = { ";", "s" },
	[40] = { "'", "-" },
	[41] = { "<ENTER>", "<ENTER>" },
	[42] = { "<LSHIFT>", "<LSHIFT>" },
	[43] = { "z", ";" },
	[44] = { "x", "q" },
	[45] = { "c", "j" },
	[46] = { "v", "k" },
	[47] = { "b", "x" },
	[48] = { "n", "b" },
	[49] = { "m", "m" },
	[50] = { ",", "w" },
	[51] = { ".", "v" },
	[52] = { "/", "z" },
	[53] = { "<RSHIFT>", "<RSHIFT>" },
}

-- list of supported layouts
M.layouts = {
	["qwerty"] = qwerty_keys,
	["dvorak"] = dvorak_keys,
}

local function center(str, width, shift_left)
	local total_padding = width - strlen(str)
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
function M.render(layout)
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

	local ret = Layout:new()

	-- prepare a table to hold the keycaps
	local key_strings = {}
	-- keep track of the column within each row for the keycap
	local column_index = 1
	-- keep track of the row on the keyboard display
	local row_index = 1
	-- keep track of the longest row
	local longest_row_length = 0
	-- place keys in rows
	for i = 1, #layout do
		local keycap = strformat(" %s ", layout[i][2])
		-- store the keycap label
		key_strings[column_index] = keycap
		-- this is more efficient than using `table.insert`
		column_index = column_index + 1
		local row_len = row_lengths[row_index] or 0
		-- add 1 for counting the separator
		row_lengths[row_index] = row_len + strlen(keycap) + 1
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
		rows[i][1] = center(rows[i][1], strlen(rows[i][1]) + start_column_pad)
		rows[i][end_column] = center(rows[i][end_column], strlen(rows[i][end_column]) + end_column_pad)
	end

	-- calculate keycap separator locations
	for i = 1, #rows do
		local row = rows[i]
		local row_length = 0
		for col = 1, #row do
			local keycap = row[col]
			-- add the length of the separator
			row_length = row_length + strlen(keycap) + 1
			-- mark where there is a separator
			keycap_separator_columns[i][row_length] = true
		end
	end

	-- place top row
	local final_rows = {}
	local top_row = { charset[" s s"] }
	for col = 1, #rows[1] do
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
		table.insert(final_rows, "│" .. table.concat(row, "│") .. "│")
		table.insert(final_rows, table.concat(new_row, ""))
	end

	ret.row_length = longest_row_length
	ret.layout = final_rows
	return ret
end

--print(table.concat(M.render(M.layouts["dvorak"]), "\n"))
return M
