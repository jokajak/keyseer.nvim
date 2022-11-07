local Layout = require("keymaster.layout")

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
    assert.combinators.match(qwerty_layout, layout:layout().lines)
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
    assert.combinators.match(dvorak_layout, layout:layout().lines)
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
    local res = layout:layout().lines
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
    assert.combinators.match(qwerty_key_label_layout, layout:layout().lines)
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
    local res = layout:layout().lines
    assert.combinators.match(vert_qwerty_layout, res)
  end)
end)
