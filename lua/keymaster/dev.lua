--[[ local mode = "n"
local keymaps = buf and vim.api.nvim_buf_get_keymap(buf, mode) or vim.api.nvim_get_keymap(mode)
for _, keymap in pairs(keymaps) do
  print(keymap.lhs)
end ]]

require("keymaster").reset()
require("keymaster").show({ prefix = "," })
