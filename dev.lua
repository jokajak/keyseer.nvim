local qwerty = require("keyfinder.keyboard.qwerty")

local keyboard = qwerty:new()

print(vim.pretty_print(qwerty.get_lines))
print(vim.pretty_print(keyboard.get_lines))
local Display = require("keyfinder.display")

local display = Display:new({
  show_legend = true,
  show_title = false,
  keyboard = {
    layout = "qwerty",
    padding = { 0, 1, 0, 1 },
  },
})
display:open()
