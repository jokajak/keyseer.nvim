local helpers = dofile("tests/helpers.lua")

-- See https://github.com/echasnovski/mini.nvim/blob/main/lua/mini/test.lua for more documentation

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

T["new()"] = MiniTest.new_set()
-- Tests related to the new method
T["new()"]["sets exposed methods and default options value"] = function()
  child.lua([[display = require("keyfinder.display"):new()]])

  eq_type_global(child, "display", "table")

  -- public methods
  eq_type_global(child, "display.open", "function")
  eq_type_global(child, "display.close", "function")

  eq_type_global(child, "display._keyboard", "table")
end

return T
