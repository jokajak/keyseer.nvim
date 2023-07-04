-- Built in keymaps-- preset key allocations in vim
local M = {
  n = {},
  v = {},
}

local normal_mappings = {
  ["!"] = "Filter though external program",
  ["$"] = "End of line",
  ["%"] = "Matching character: '()', '{}', '[]'",
  ["'"] = "Jump to mark",
  [","] = "Repeat latest f, t, F or T [count] times in opposite direction",
  ["."] = "Repeat last operation",
  ["/"] = "Search",
  ["0"] = "Start of line",
  [";"] = "Repeat latest f, t, F or T [count] times",
  ["<C-R>"] = "Redo",
  ["<lt>"] = "Indent left",
  [">"] = "Indent right",
  ["a"] = "Append",
  ["A"] = "Append to end if line",
  ["F"] = "Move to previous char",
  ["G"] = "Last line",
  ["i"] = "Insert",
  ["I"] = "Insert at start of line",
  ["n"] = "Next search result",
  ["N"] = "Repeat last search in opposite direction",
  ["o"] = "Insert on line below",
  ["O"] = "Insert on line above",
  ["R"] = "Replace",
  ["T"] = "Move before previous char",
  ["^"] = "Start of line (non-blank)",
  ["b"] = "Previous word",
  ["c"] = "Change",
  ["cc"] = "Change the whole line",
  ["C"] = "Change to end of line",
  ["d"] = "Delete",
  ["D"] = "Delete to end of line",
  ["e"] = "forward to the end of word [count] |inclusive|.",
  ["E"] = "Forward to the end of WORD [count] |inclusive|.",
  ["f"] = "Move to next char",
  ["h"] = "Left",
  ["j"] = "Down",
  ["k"] = "Up",
  ["l"] = "Right",
  ["m"] = "Mark",
  ["p"] = "Put (paste) before",
  ["P"] = "Put (paste) after",
  ["q"] = "Complex repeats, aka macro",
  ["s"] = "Substitute",
  ["t"] = "Move before next char",
  ["u"] = "Undo",
  ["v"] = "Visual Character Mode",
  ["V"] = "Visual Line Mode",
  ["<C-v>"] = "Visual Block Mode",
  ["w"] = "Next word",
  ["W"] = "Next word on whitespace",
  ["x"] = "Cut character under cursor",
  ["y"] = "Yank (copy)",
  ["zf"] = "Create fold",
  ["{"] = "Previous empty line",
  ["}"] = "Next empty line",
  ["gU"] = "Uppercase",
  ["ge"] = "Previous end of word",
  ["gg"] = "First line",
  ["gu"] = "Lowercase",
  ["g~"] = "Toggle case",
}

for k, v in pairs(normal_mappings) do
  table.insert(M.n, {
    lhs = k,
    rhs = k,
    desc = v,
  })
end

return M
