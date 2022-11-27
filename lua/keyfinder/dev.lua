--[[ local mode = "n"
local keymaps = buf and vim.api.nvim_buf_get_keymap(buf, mode) or vim.api.nvim_get_keymap(mode)
for _, keymap in pairs(keymaps) do
  print(keymap.lhs)
end ]]

require("keyfinder").reset()
require("keyfinder.config").setup({
  key_labels = {
    -- override the label used to display some keys. It doesn't effect KM in any other way.
    -- For example:
    -- ["<space>"] = "SPC",
    -- ["<cr>"] = "RET",
    -- ["<tab>"] = "TAB",
    padding = { 1, 1, 1, 1 }, -- padding around keycap labels [top, right, bottom, left]
    highlight_padding = { 1, 2, 1, 2 }, -- how much of the label to highlight
  },
})
require("keyfinder").show({})
