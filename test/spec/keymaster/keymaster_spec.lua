local keymaster = require('keymaster')

/* describe("greeting", function()
   it('works!', function()
      assert.combinators.match("Hello Gabo", my_cool_module.greeting("Gabo"))
   end)
end) */

local qwerty_layout = {
    "┌──────┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬──────┐",
    "│  `   │1│2│3│4│5│6│7│8│9│0│-│=│ <BS> │",
    "├──────┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼──────┤",
    "│<TAB> │q│w│e│r│t│y│u│i│o│p│[│]│  \   │",
    "├──────┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┴──────┤",
    "│<CAPS>│a│s│d│f│g│h│j│k│l│;│'│ <ENTER>│",
    "├──────┴─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼────────┤",
    "│<LSHIFT>│z│x│c│v│b│n│m│,│.│/│<RSHIFT>│",
    "└────────┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴────────┘",
}

describe("qwerty_layout_test", function()
  it('renders_qwerty', function()
    assert.combinators.match(qwerty_layout, layouts.render("qwerty"))
  end)
end)

local dvorak_layout = {
    "┌──────┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬──────┐",
    "│  `   │1│2│3│4│5│6│7│8│9│0│-│=│ <BS> │",
    "├──────┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼──────┤",
    "│<TAB> │'│,│.│p│y│f│g│c│r│l│/│=│  \   │",
    "├──────┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┴──────┤",
    "│<CAPS>│a│o│e│u│i│d│h│t│n│s│-│ <ENTER>│",
    "├──────┴─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼────────┤",
    "│<LSHIFT>│;│q│j│k│x│b│m│w│v│z│<RSHIFT>│",
    "└────────┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴────────┘",
}
