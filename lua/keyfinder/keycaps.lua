---@class KeycodeMap
---@field qwerty_keycap string The keycap on a qwerty keyboard
---@field keycode string The neovim keycode

local M = {}

---@type KeycodeMap[]
M.qwerty = {
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
  [42] = { "<Shift>", "<SHIFT>" },
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
  [53] = { "<Shift>", "<SHIFT>" },
  [54] = { "<CTRL>", "<CTRL>" },
  [55] = { "<Super>", "<SUPER>" },
  [56] = { "<ALT>", "<ALT>" },
  [57] = { "<Space>", "<SPACE>" },
  [58] = { "<Alt>", "<ALT>" },
  [59] = { "<Ctrl>", "<CTRL>" },
}

M.dvorak = {
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
  [42] = { "<Shift>", "<SHIFT>" },
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
  [53] = { "<Shift>", "<SHIFT>" },
  [54] = { "<CTRL>", "<CTRL>" },
  [55] = { "<Super>", "<SUPER>" },
  [56] = { "<ALT>", "<ALT>" },
  [57] = { "<Space>", "<SPACE>" },
  [58] = { "<Alt>", "<ALT>" },
  [59] = { "<Ctrl>", "<CTRL>" },
}

return M
