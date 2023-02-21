local Keys = require("keyfinder.keys")

local extract_key_order = Keys.parse_keymap_lhs

describe("multi_key_extract_test", function()
  it("extracts_keys", function()
    assert.combinators.match({ { "," }, { "g" } }, extract_key_order(",g"))
    assert.combinators.match({ { "<Space>" }, { "g" } }, extract_key_order(" g"))
    assert.combinators.match({ { "<Space>" }, { "<Ctrl>", "d" } }, extract_key_order(" <C-d>"))
    assert.combinators.match({ { "<Space>" }, { "<Ctrl>", "<Space>" } }, extract_key_order(" <C-Space>"))
    assert.combinators.match({ { "<Space>" }, { "<Ctrl>", "-" }, { "<Space>" } }, extract_key_order(" <C--> "))
  end)
end)
