-- Built in keymaps-- preset key allocations in vim
local M = {
  n = {},
  v = {},
}

local normal_mappings = {
  ["h"] = "Left",
  ["j"] = "Down",
  ["k"] = "Up",
  ["l"] = "Right",
  ["w"] = "Next word",
  ["%"] = "Matching character: '()', '{}', '[]'",
  ["b"] = "Previous word",
  ["e"] = "Next end of word",
  ["ge"] = "Previous end of word",
  ["0"] = "Start of line",
  ["^"] = "Start of line (non-blank)",
  ["$"] = "End of line",
  ["f"] = "Move to next char",
  ["F"] = "Move to previous char",
  ["t"] = "Move before next char",
  ["T"] = "Move before previous char",
  ["gg"] = "First line",
  ["G"] = "Last line",
  ["{"] = "Previous empty line",
  ["}"] = "Next empty line",
  d = "Delete",
  c = "Change",
  y = "Yank (copy)",
  ["g~"] = "Toggle case",
  ["gu"] = "Lowercase",
  ["gU"] = "Uppercase",
  [">"] = "Indent right",
  ["<lt>"] = "Indent left",
  ["zf"] = "Create fold",
  ["!"] = "Filter though external program",
  ["v"] = "Visual Character Mode",
  ["x"] = "Cut character under cursor",
  ["A"] = "Append to end if line",
  ["o"] = "Insert on line below",
  ["O"] = "Insert on line above",
  ["<C-R>"] = "Redo",
  ["u"] = "Undo",
  ["p"] = "Put (paste)",
  ["i"] = "Insert",
  ["I"] = "Insert at start of line",
  [";"] = "Repeat latest f, t, F or T [count] times",
  [","] = "Repeat latest f, t, F or T [count] times in opposite direction",
  ["s"] = "Substitute",
  ["m"] = "Mark",
  ["n"] = "Next search result",
  ["N"] = "Repeat last search in opposite direction",
  ["."] = "Repeat last operation",
  ["/"] = "Search",
  ["q"] = "Complex repeats, aka macro",
  ["'"] = "Jump to mark",
}

for k, v in pairs(normal_mappings) do
  table.insert(M.n, {
    lhs = k,
    rhs = k,
    desc = v,
  })
end

return M
