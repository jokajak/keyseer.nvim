local Layout = require("keyfinder.layout")
local Keys = require("keyfinder.keys")

local qwerty_layout = {
  "┌─────┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬────────┐",
  "│  `  │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │ 7 │ 8 │ 9 │ 0 │ - │ = │  <BS>  │",
  "├─────┴───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┬────┤",
  "│  <TAB>  │ q │ w │ e │ r │ t │ y │ u │ i │ o │ p │ [ │ ] │  \\ │",
  "├────────┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴───┴────┤",
  "│ <CAPS> │ a │ s │ d │ f │ g │ h │ j │ k │ l │ ; │ ' │ <ENTER> │",
  "├────────┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴─────────┤",
  "│  <SHIFT>  │ z │ x │ c │ v │ b │ n │ m │ , │ . │ / │  <SHIFT> │",
  "├────────┬──┴───┴──┬┴───┴──┬┴───┴───┴───┴───┴─┬─┴───┴─┬────────┤",
  "│ <CTRL> │ <SUPER> │ <ALT> │      <SPACE>     │ <ALT> │ <CTRL> │",
  "└────────┴─────────┴───────┴──────────────────┴───────┴────────┘",
}

describe("qwerty_layout_test", function()
  it("renders_qwerty", function()
    local layout = Layout:new({ layout = "qwerty" })
    assert.combinators.match(qwerty_layout, layout:calculate_layout().lines)
  end)
end)

local dvorak_layout = {
  "┌─────┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬────────┐",
  "│  `  │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │ 7 │ 8 │ 9 │ 0 │ [ │ ] │  <BS>  │",
  "├─────┴───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┬────┤",
  "│  <TAB>  │ ' │ , │ . │ p │ y │ f │ g │ c │ r │ l │ / │ = │  \\ │",
  "├────────┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴───┴────┤",
  "│ <CAPS> │ a │ o │ e │ u │ i │ d │ h │ t │ n │ s │ - │ <ENTER> │",
  "├────────┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴─────────┤",
  "│  <SHIFT>  │ ; │ q │ j │ k │ x │ b │ m │ w │ v │ z │  <SHIFT> │",
  "├────────┬──┴───┴──┬┴───┴──┬┴───┴───┴───┴───┴─┬─┴───┴─┬────────┤",
  "│ <CTRL> │ <SUPER> │ <ALT> │      <SPACE>     │ <ALT> │ <CTRL> │",
  "└────────┴─────────┴───────┴──────────────────┴───────┴────────┘",
}

describe("dvorak_layout_test", function()
  it("renders_dvorak", function()
    local layout = Layout:new({ layout = "dvorak" })
    assert.combinators.match(dvorak_layout, layout:calculate_layout().lines)
  end)
end)

local no_pad_qwerty_layout = {
  "┌───────┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─────────┐",
  "│   `   │1│2│3│4│5│6│7│8│9│0│-│=│   <BS>  │",
  "├───────┴─┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬─┬──────┤",
  "│  <TAB>   │q│w│e│r│t│y│u│i│o│p│[│]│   \\  │",
  "├─────────┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴─┴──────┤",
  "│ <CAPS>  │a│s│d│f│g│h│j│k│l│;│'│ <ENTER> │",
  "├─────────┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴─────────┤",
  "│ <SHIFT>  │z│x│c│v│b│n│m│,│.│/│  <SHIFT> │",
  "├──────┬───┴─┴─┼─┴─┴─┼─┴─┴─┴─┼─┴───┬──────┤",
  "│<CTRL>│<SUPER>│<ALT>│<SPACE>│<ALT>│<CTRL>│",
  "└──────┴───────┴─────┴───────┴─────┴──────┘",
}
describe("qwerty_no_pad_layout_test", function()
  it("renders_qwerty", function()
    local layout = Layout:new({ layout = "qwerty", key_labels = { padding = { 0, 0, 0, 0 } } })
    local res = layout:calculate_layout().lines
    assert.combinators.match(no_pad_qwerty_layout, res)
  end)
end)

local qwerty_key_label_layout = {
  "┌────┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬──────┐",
  "│ `  │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │ 7 │ 8 │ 9 │ 0 │ - │ = │ <BS> │",
  "├────┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬───┤",
  "│ <TAB> │ q │ w │ e │ r │ t │ y │ u │ i │ o │ p │ [ │ ] │ \\ │",
  "├───────┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴───┤",
  "│ <CAPS>  │ a │ s │ d │ f │ g │ h │ j │ k │ l │ ; │ ' │ RET │",
  "├─────────┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┴─────┤",
  "│ <SHIFT> │ z │ x │ c │ v │ b │ n │ m │ , │ . │ / │ <SHIFT> │",
  "├────────┬┴───┴───┴┬──┴───┴┬──┴───┴───┴───┴┬──┴───┴┬────────┤",
  "│ <CTRL> │ <SUPER> │ <ALT> │    <SPACE>    │ <ALT> │ <CTRL> │",
  "└────────┴─────────┴───────┴───────────────┴───────┴────────┘",
}

describe("qwerty_key_cap_test", function()
  it("renders_qwerty", function()
    local layout = Layout:new({ layout = "qwerty", key_labels = { ["<ENTER>"] = "RET" } })
    assert.combinators.match(qwerty_key_label_layout, layout:calculate_layout().lines)
  end)
end)

local vert_qwerty_layout = {
  "┌───────┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─────────┐",
  "│       │ │ │ │ │ │ │ │ │ │ │ │ │         │",
  "│   `   │1│2│3│4│5│6│7│8│9│0│-│=│   <BS>  │",
  "│       │ │ │ │ │ │ │ │ │ │ │ │ │         │",
  "├───────┴─┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬─┬──────┤",
  "│          │ │ │ │ │ │ │ │ │ │ │ │ │      │",
  "│  <TAB>   │q│w│e│r│t│y│u│i│o│p│[│]│   \\  │",
  "│          │ │ │ │ │ │ │ │ │ │ │ │ │      │",
  "├─────────┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴─┴──────┤",
  "│         │ │ │ │ │ │ │ │ │ │ │ │         │",
  "│ <CAPS>  │a│s│d│f│g│h│j│k│l│;│'│ <ENTER> │",
  "│         │ │ │ │ │ │ │ │ │ │ │ │         │",
  "├─────────┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴─────────┤",
  "│          │ │ │ │ │ │ │ │ │ │ │          │",
  "│ <SHIFT>  │z│x│c│v│b│n│m│,│.│/│  <SHIFT> │",
  "│          │ │ │ │ │ │ │ │ │ │ │          │",
  "├──────┬───┴─┴─┼─┴─┴─┼─┴─┴─┴─┼─┴───┬──────┤",
  "│      │       │     │       │     │      │",
  "│<CTRL>│<SUPER>│<ALT>│<SPACE>│<ALT>│<CTRL>│",
  "│      │       │     │       │     │      │",
  "└──────┴───────┴─────┴───────┴─────┴──────┘",
}
describe("vert_pad_layout_test", function()
  it("renders_qwerty", function()
    local layout = Layout:new({ layout = "qwerty", key_labels = { padding = { 1, 0, 1, 0 } } })
    local res = layout:calculate_layout().lines
    assert.combinators.match(vert_qwerty_layout, res)
  end)
end)

describe("multi_key_extract_test", function()
  it("extracts_keys", function()
    local res = Keys.extract_key_order(",g")
    assert.combinators.match({
      keys = { ",", "g" },
      keycaps = { { "," }, { "g" } },
    }, res)
  end)
end)

describe("special_key_test", function()
  it("extracts_keys", function()
    local res = Keys.extract_key_order("<C-i>")
    assert.combinators.match({
      keys = { "<C-i>" },
      keycaps = { { "<C>", "i" } },
    }, res)
  end)
end)

describe("q_keycap_position_test", function()
  local layout = Layout:new({ layout = "qwerty", key_labels = { padding = { 0, 1, 0, 1 } } })
  layout:calculate_layout()
  it("gets_the_row", function()
    local button = layout.buttons["q"][1]
    assert.combinators.match(3, button.row)
  end)
  it("gets_the_column", function()
    local button = layout.buttons["0"][1]
    assert.combinators.match(65, button.left_byte_col)
    assert.combinators.match(68, button.right_byte_col)
  end)
  it("pads_left", function()
    local h_layout =
      Layout:new({ layout = "qwerty", key_labels = { padding = { 0, 1, 0, 1 }, highlight_padding = { 0, 1, 0, 0 } } })
    h_layout:calculate_layout()
    local res = h_layout.buttons["0"][1]
    assert.combinators.match(1, res.row)
    assert.combinators.match(65, res.left_byte_col)
    assert.combinators.match(68, res.right_byte_col)
  end)
  it("calculates_backtick_pos", function()
    -- | ` |
    --│  `  │
    --1234567 <-- character positions
    -- ^--- start of button, byte = 3
    --      ^-- end of button, byte = 3 + 5 (width of button)
    local res = layout.buttons["`"][1]
    assert.combinators.match(1, res.row)
    assert.combinators.match(3, res.left_byte_col)
    assert.combinators.match(8, res.right_byte_col)
  end)
  it("highlights_right", function()
    local h_layout =
      Layout:new({ layout = "qwerty", key_labels = { padding = { 0, 1, 0, 1 }, highlight_padding = { 0, 0, 0, 1 } } })
    h_layout:calculate_layout()
    local res = h_layout.buttons["0"][1]
    assert.combinators.match(1, res.row)
    assert.combinators.match(65, res.left_byte_col)
    assert.combinators.match(68, res.right_byte_col)
  end)
end)

describe("keycap_special_lower_tests", function()
  local Keycap = require("keyfinder.keycap")
  it("convers_four", function()
    assert.combinators.match("4", Keycap.to_lower("$"))
    assert.combinators.match("$", Keycap.to_upper("$"))
  end)
end)
