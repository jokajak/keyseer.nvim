-- Built in keymaps-- preset key allocations in vim
---@private
local function keymapLike(t)
  local mt = {
    __newindex = function(tbl, key, value)
      local keymap = {
        lhs = key,
        rhs = key,
        desc = value,
      }
      rawset(tbl, #tbl + 1, keymap)
    end,
  }
  setmetatable(t, mt)
  return t
end

local M = setmetatable({}, {
  __index = function(tbl, key)
    rawset(tbl, key, keymapLike({}))
    return tbl[key]
  end,
})

M.n["!"] = "Filter though external program"
M.n["&"] = ":&&<CR>"
M.n["$"] = "End of line"
M.n["%"] = "Matching character: '()', '{}', '[]'"
M.n["'"] = "Jump to mark"
M.n[","] = "Repeat latest f, t, F or T [count] times in opposite direction"
M.n["."] = "Repeat last operation"
M.n["/"] = "Search"
M.n["0"] = "Start of line"
M.n[";"] = "Repeat latest f, t, F or T [count] times"
M.n["<C-R>"] = "Redo"
M.n["<lt>"] = "Indent left"
M.n[">"] = "Indent right"
M.n["a"] = "Append"
M.n["A"] = "Append to end if line"
M.n["F"] = "Move to previous char"
M.n["G"] = "Last line"
M.n["i"] = "Insert"
M.n["I"] = "Insert at start of line"
M.n["n"] = "Next search result"
M.n["N"] = "Repeat last search in opposite direction"
M.n["o"] = "Insert on line below"
M.n["O"] = "Insert on line above"
M.n["r"] = "Replace current character"
M.n["R"] = "Enter Replace mode"
M.n["T"] = "Move before previous char"
M.n["^"] = "Start of line (non-blank)"
M.n["b"] = "Previous word"
M.n["c"] = "Change"
M.n["cc"] = "Change the whole line"
M.n["C"] = "Change to end of line"
M.n["d"] = "Delete"
M.n["D"] = "Delete to end of line"
M.n["e"] = "forward to the end of word [count] |inclusive|."
M.n["E"] = "Forward to the end of WORD [count] |inclusive|."
M.n["f"] = "Move to next char"
M.n["<C-L>"] = "See :help <C-L>"
M.n["h"] = "Left"
M.n["j"] = "Down"
M.n["k"] = "Up"
M.n["l"] = "Right"
M.n["m"] = "Mark"
M.n["p"] = "Put (paste) before"
M.n["P"] = "Put (paste) after"
M.n["q"] = "Complex repeats, aka macro"
M.n["s"] = "Substitute"
M.n["S"] = "Synonym for cc"
M.n["t"] = "Move before next char"
M.n["u"] = "Undo"
M.n["v"] = "Visual Character Mode"
M.n["V"] = "Visual Line Mode"
M.n["<C-V>"] = "Visual Block Mode"
M.n["w"] = "Next word"
M.n["W"] = "Next word on whitespace"
M.n["x"] = "Cut character under cursor"
M.n["y"] = "Yank (copy)"
M.n["Y"] = "Yank (copy) to end of line"
M.n["zf"] = "Create fold"
M.n["{"] = "Previous empty line"
M.n["}"] = "Next empty line"
M.n["gU"] = "Uppercase"
M.n["ge"] = "Previous end of word"
M.n["gg"] = "First line"
M.n["gu"] = "Lowercase"
M.n["g~"] = "Toggle case"
M.n["g`"] = "Jump to mark"
M.n["g'"] = "Jump to mark"
M.n["<Space>"] = "Move right"
M.n["<F1>"] = "Open Help"
M.n["`"] = "Jump to mark"
M.n["~"] = "Switch case of character under cursor and move to the right."
M.n["Up"] = "Up"
M.n["Down"] = "Down"
M.n["Left"] = "Left"
M.n["Right"] = "Right"
M.n["<Tab>"] = "See :help <Tab>"

M.v["#"] = '* y?\\V<C-R>"<CR>'
M.v["*"] = '* y?\\V<C-R>"<CR>'

M.x["#"] = '* y?\\V<C-R>"<CR>'
M.x["*"] = '* y?\\V<C-R>"<CR>'

M.i["<C-U>"] = "See :help i_CTRL-U"
M.i["<C-W>"] = "See :help i_CTRL-W"
M.i["<C-O>"] = "see :help i_CTRL-O"
M.i["<C-c>"] = "See :help i_CTRL-c"
M.i["<Esc>"] = "See :help i_<Esc>"
M.i["<C-@>"] = "See :help i_CTRL-@"
M.i["<C-A>"] = "See :help i_CTRL-A"
M.i["<C-N>"] = "See :help i_CTRL-N"
M.i["<C-P>"] = "See :help i_CTRL-P"
M.i["<C-R>"] = "See :help i_CTRL-R"
M.i["<C-R><C-R>"] = "See :help i_CTRL-R_CTRL-R"
M.i["<C-R><C-O>"] = "See :help i_CTRL-R_CTRL-O"
M.i["<C-R><C-P>"] = "See :help i_CTRL-R_CTRL-P"
M.i["<S-Up>"] = "See :help i_<S-Up>"

return M
