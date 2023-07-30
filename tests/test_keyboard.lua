-- Tests for the keyboard class
local helpers = dofile("tests/helpers.lua")

local child = helpers.new_child_neovim()
local eq_global, eq_config, eq_state =
  helpers.expect.global_equality, helpers.expect.config_equality, helpers.expect.state_equality
local eq_type_global, eq_type_config, eq_type_state =
  helpers.expect.global_type_equality,
  helpers.expect.config_type_equality,
  helpers.expect.state_type_equality

local T = MiniTest.new_set({
  hooks = {
    -- This will be executed before every (even nested) case
    pre_case = function()
      -- Restart child process with custom 'init.lua' script
      child.restart({ "-u", "scripts/minimal_init.lua" })
      child.lua([[qwerty = require('keyseer.keyboard.qwerty')]])
      child.lua([[dvorak = require('keyseer.keyboard.dvorak')]])
    end,
    -- This will be executed one after all tests from this set are finished
    post_once = child.stop,
  },
})
local qwerty_layout = {
  "┌─────┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬────────┐",
  "│  `  │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │ 7 │ 8 │ 9 │ 0 │ - │ = │  <BS>  │",
  "├─────┴───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┬────┤",
  "│  <Tab>  │ q │ w │ e │ r │ t │ y │ u │ i │ o │ p │ [ │ ] │  \\ │",
  "├────────┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴───┴────┤",
  "│ <Caps> │ a │ s │ d │ f │ g │ h │ j │ k │ l │ ; │ ' │ <Enter> │",
  "├────────┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴─────────┤",
  "│  <Shift>  │ z │ x │ c │ v │ b │ n │ m │ , │ . │ / │  <Shift> │",
  "├────────┬──┴───┴─┬─┴───┴───┴┬──┴───┴─┬─┴───┴──┬┴──┬┴──┬───┬───┤",
  "│ <Ctrl> │ <Meta> │  <Space> │ <Meta> │ <Ctrl> │ ← │ ↑ │ ↓ │ → │",
  "└────────┴────────┴──────────┴────────┴────────┴───┴───┴───┴───┘",
}
local qwerty_shift_pressed_layout = {
  "┌─────┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬────────┐",
  "│  ~  │ ! │ @ │ # │ $ │ % │ ^ │ & │ * │ ( │ ) │ _ │ + │  <BS>  │",
  "├─────┴───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┬────┤",
  "│  <Tab>  │ Q │ W │ E │ R │ T │ Y │ U │ I │ O │ P │ { │ } │  | │",
  "├────────┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴───┴────┤",
  '│ <Caps> │ A │ S │ D │ F │ G │ H │ J │ K │ L │ : │ " │ <Enter> │',
  "├────────┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴─────────┤",
  "│  <Shift>  │ Z │ X │ C │ V │ B │ N │ M │ < │ > │ ? │  <Shift> │",
  "├────────┬──┴───┴─┬─┴───┴───┴┬──┴───┴─┬─┴───┴──┬┴──┬┴──┬───┬───┤",
  "│ <Ctrl> │ <Meta> │  <Space> │ <Meta> │ <Ctrl> │ ← │ ↑ │ ↓ │ → │",
  "└────────┴────────┴──────────┴────────┴────────┴───┴───┴───┴───┘",
}

T["qwerty"] = MiniTest.new_set()

T["qwerty"]["can access keyboard object"] = function()
  eq_type_global(child, "qwerty", "table")
end
T["qwerty"]["has a layout"] = function()
  eq_type_global(child, "_G.qwerty.layout", "table")
end

T["qwerty"]["has config"] = function()
  eq_type_global(child, "_G.qwerty.padding", "table")
  eq_type_global(child, "_G.qwerty.highlight_padding", "table")
  eq_type_global(child, "_G.qwerty.key_labels", "table")
  eq_type_global(child, "_G.qwerty.shift_pressed", "boolean")
  eq_global(child, "_G.qwerty.shift_pressed", false)
end

T["qwerty"]["calculates normal layout"] = function()
  eq_type_global(child, "qwerty", "table")
  eq_type_global(child, "qwerty.get_lines", "function")
  eq_global(child, "qwerty:get_lines()", qwerty_layout)
end

T["qwerty"]["calculates shift pressed layout"] = function()
  eq_global(child, "qwerty:get_lines(true)", qwerty_shift_pressed_layout)
end

T["qwerty"]["calculates size"] = function()
  child.lua([[qwerty:get_lines(false)]])
  eq_global(child, "qwerty.height", 11)
  eq_global(child, "qwerty.width", 64)
end

local dvorak_layout = {
  "┌─────┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬────────┐",
  "│  `  │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │ 7 │ 8 │ 9 │ 0 │ [ │ ] │  <BS>  │",
  "├─────┴───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┬────┤",
  "│  <Tab>  │ ' │ , │ . │ p │ y │ f │ g │ c │ r │ l │ / │ = │  \\ │",
  "├────────┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴───┴────┤",
  "│ <Caps> │ a │ o │ e │ u │ i │ d │ h │ t │ n │ s │ - │ <Enter> │",
  "├────────┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴─────────┤",
  "│  <Shift>  │ ; │ q │ j │ k │ x │ b │ m │ w │ v │ z │  <Shift> │",
  "├────────┬──┴───┴─┬─┴───┴───┴┬──┴───┴─┬─┴───┴──┬┴──┬┴──┬───┬───┤",
  "│ <Ctrl> │ <Meta> │  <Space> │ <Meta> │ <Ctrl> │ ← │ ↑ │ ↓ │ → │",
  "└────────┴────────┴──────────┴────────┴────────┴───┴───┴───┴───┘",
}

local dvorak_shift_pressed_layout = {
  "┌─────┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬────────┐",
  "│  ~  │ ! │ @ │ # │ $ │ % │ ^ │ & │ * │ ( │ ) │ { │ } │  <BS>  │",
  "├─────┴───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┬────┤",
  '│  <Tab>  │ " │ < │ > │ P │ Y │ F │ G │ C │ R │ L │ ? │ + │  | │',
  "├────────┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴───┴────┤",
  "│ <Caps> │ A │ O │ E │ U │ I │ D │ H │ T │ N │ S │ _ │ <Enter> │",
  "├────────┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴─────────┤",
  "│  <Shift>  │ : │ Q │ J │ K │ X │ B │ M │ W │ V │ Z │  <Shift> │",
  "├────────┬──┴───┴─┬─┴───┴───┴┬──┴───┴─┬─┴───┴──┬┴──┬┴──┬───┬───┤",
  "│ <Ctrl> │ <Meta> │  <Space> │ <Meta> │ <Ctrl> │ ← │ ↑ │ ↓ │ → │",
  "└────────┴────────┴──────────┴────────┴────────┴───┴───┴───┴───┘",
}
T["dvorak"] = MiniTest.new_set()

T["dvorak"]["calculates normal layout"] = function()
  eq_type_global(child, "dvorak", "table")
  eq_type_global(child, "dvorak.get_lines", "function")
  eq_global(child, "dvorak:get_lines()", dvorak_layout)
end

T["dvorak"]["calculates shift pressed layout"] = function()
  eq_global(child, "dvorak:get_lines(true)", dvorak_shift_pressed_layout)
end

return T
