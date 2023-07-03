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
      child.lua([[utils = require("keyseer.utils")]])
    end,
    -- This will be executed one after all tests from this set are finished
    post_once = child.stop,
  },
})

T["utils"] = MiniTest.new_set()
-- Tests related to the new method
T["utils"]["has api"] = function()
  eq_type_global(child, "utils", "table")

  -- public methods
  eq_type_global(child, "utils.justify", "function")
  eq_type_global(child, "utils.parse_keystring", "function")
end

T["utils"]["parses keystrings"] = function()
  eq_global(child, "utils.parse_keystring(',g')", { { "," }, { "g" } })
  eq_global(child, "utils.parse_keystring(' g')", { { "<Space>" }, { "g" } })
  eq_global(child, "utils.parse_keystring(' <C-d>')", { { "<Space>" }, { "<Ctrl>", "d" } })
  eq_global(
    child,
    "utils.parse_keystring(' <C-Space>')",
    { { "<Space>" }, { "<Ctrl>", "<Space>" } }
  )
  eq_global(
    child,
    "utils.parse_keystring(' <C--> ')",
    { { "<Space>" }, { "<Ctrl>", "-" }, { "<Space>" } }
  )
end

T["buttons"] = MiniTest.new_set()
T["buttons"]["has public API"] = function()
  child.lua([[buttons = require("keyseer.util.buttons")]])
  eq_type_global(child, "buttons", "table")
  eq_type_global(child, "buttons.shifted_keys", "string")
  eq_type_global(child, "buttons.unshifted_keys", "string")
end
T["buttons"]["generates 1"] = function()
  child.lua([[buttons = require("keyseer.util.buttons")]])
  eq_global(child, "buttons['a']", "A")
  eq_global(child, "buttons['1']", "!")
  eq_global(child, "buttons['`']", "~")
end

T["buttons"]["describes shifted"] = function()
  child.lua([[buttons = require("keyseer.util.buttons")]])
  eq_global(child, "buttons.shifted_keys:find('A', 0, true)", 11)
  eq_global(child, "buttons.shifted_keys:find('a', 0, true)", vim.NIL)
  eq_global(child, "buttons.shifted_keys:find('`', 0, true)", vim.NIL)
  eq_global(child, "buttons.shifted_keys:find('\"', 0, true)", 43)
end

T["utils"]["parse_keystring supports split_keypresses"] = function()
  eq_global(child, "utils.parse_keystring('<C-g>', false)", { { "<C-g>" } })
  eq_global(child, "utils.parse_keystring('<C-g>', true)", { { "<Ctrl>", "g" } })
end

return T
