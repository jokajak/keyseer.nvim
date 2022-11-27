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
  "│ <LSHIFT>  │ z │ x │ c │ v │ b │ n │ m │ , │ . │ / │ <RSHIFT> │",
  "└───────────┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴──────────┘",
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
  "│ <LSHIFT>  │ ; │ q │ j │ k │ x │ b │ m │ w │ v │ z │ <RSHIFT> │",
  "└───────────┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴──────────┘",
}

describe("dvorak_layout_test", function()
  it("renders_dvorak", function()
    local layout = Layout:new({ layout = "dvorak" })
    assert.combinators.match(dvorak_layout, layout:calculate_layout().lines)
  end)
end)

local no_pad_qwerty_layout = {
  "┌─────┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬───────┐",
  "│  `  │1│2│3│4│5│6│7│8│9│0│-│=│  <BS> │",
  "├─────┴─┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬─┬────┤",
  "│ <TAB>  │q│w│e│r│t│y│u│i│o│p│[│]│  \\ │",
  "├───────┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴─┴────┤",
  "│<CAPS> │a│s│d│f│g│h│j│k│l│;│'│<ENTER>│",
  "├───────┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴───────┤",
  "│<LSHIFT>│z│x│c│v│b│n│m│,│.│/│<RSHIFT>│",
  "└────────┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴────────┘",
}
describe("qwerty_no_pad_layout_test", function()
  it("renders_qwerty", function()
    local layout = Layout:new({ layout = "qwerty", key_labels = { padding = { 0, 0, 0, 0 } } })
    local res = layout:calculate_layout().lines
    assert.combinators.match(no_pad_qwerty_layout, res)
  end)
end)

local qwerty_key_label_layout = {
  "┌─────┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───────┐",
  "│  `  │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │ 7 │ 8 │ 9 │ 0 │ - │ = │  <BS> │",
  "├─────┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬────┤",
  "│ <TAB>  │ q │ w │ e │ r │ t │ y │ u │ i │ o │ p │ [ │ ] │  \\ │",
  "├────────┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴────┤",
  "│  <CAPS>  │ a │ s │ d │ f │ g │ h │ j │ k │ l │ ; │ ' │  RET │",
  "├──────────┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┴──────┤",
  "│ <LSHIFT> │ z │ x │ c │ v │ b │ n │ m │ , │ . │ / │ <RSHIFT> │",
  "└──────────┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴──────────┘",
}

describe("qwerty_key_cap_test", function()
  it("renders_qwerty", function()
    local layout = Layout:new({ layout = "qwerty", key_labels = { ["<ENTER>"] = "RET" } })
    assert.combinators.match(qwerty_key_label_layout, layout:calculate_layout().lines)
  end)
end)

local vert_qwerty_layout = {
  "┌─────┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬───────┐",
  "│     │ │ │ │ │ │ │ │ │ │ │ │ │       │",
  "│  `  │1│2│3│4│5│6│7│8│9│0│-│=│  <BS> │",
  "│     │ │ │ │ │ │ │ │ │ │ │ │ │       │",
  "├─────┴─┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬─┬────┤",
  "│        │ │ │ │ │ │ │ │ │ │ │ │ │    │",
  "│ <TAB>  │q│w│e│r│t│y│u│i│o│p│[│]│  \\ │",
  "│        │ │ │ │ │ │ │ │ │ │ │ │ │    │",
  "├───────┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴─┴────┤",
  "│       │ │ │ │ │ │ │ │ │ │ │ │       │",
  "│<CAPS> │a│s│d│f│g│h│j│k│l│;│'│<ENTER>│",
  "│       │ │ │ │ │ │ │ │ │ │ │ │       │",
  "├───────┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴┬┴───────┤",
  "│        │ │ │ │ │ │ │ │ │ │ │        │",
  "│<LSHIFT>│z│x│c│v│b│n│m│,│.│/│<RSHIFT>│",
  "│        │ │ │ │ │ │ │ │ │ │ │        │",
  "└────────┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴────────┘",
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
    local res = layout.keycap_positions["q"]
    assert.combinators.match(3, res.row)
    assert.combinators.match(16, res.from)
    assert.combinators.match(17, res.to)
  end)
  it("gets_the_column", function()
    local res = layout.keycap_positions["0"]
    assert.combinators.match(1, res.row)
    assert.combinators.match(66, res.from)
    assert.combinators.match(67, res.to)
  end)
  it("pads_left", function()
    local h_layout =
      Layout:new({ layout = "qwerty", key_labels = { padding = { 0, 1, 0, 1 }, highlight_padding = { 0, 1, 0, 0 } } })
    h_layout:calculate_layout()
    local res = h_layout.keycap_positions["0"]
    assert.combinators.match(1, res.row)
    assert.combinators.match(65, res.from)
    assert.combinators.match(67, res.to)
  end)
  it("calculates_backtick_pos", function()
    local res = layout.keycap_positions["`"]
    assert.combinators.match(1, res.row)
    assert.combinators.match(5, res.from)
    assert.combinators.match(6, res.to)
  end)
end)
