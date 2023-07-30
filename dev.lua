local KeySeer = require("keyseer").setup({
  debug = true,
  keyboard = {
    keycap_padding = { 0, 1, 0, 1 },
  },
  include_builtin_keymaps = true,
  ui = {
    show_header = true,
  },
})

local UI = require("keyseer.ui")
UI.show("home", "n")
