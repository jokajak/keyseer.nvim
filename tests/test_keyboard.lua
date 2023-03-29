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
    end,
    -- This will be executed one after all tests from this set are finished
    post_once = child.stop,
  },
})
-- Tests related to the `Keyboard` class.
T["qwerty"] = MiniTest.new_set()

T["qwerty"]["sets the default value of shift_pressed"] = function()
  child.lua([[require('keyfinder.keyboard.qwerty')]])

  eq_type_global(child, "_G.qwerty", "table")
end

return T
