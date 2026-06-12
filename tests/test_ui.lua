local helpers = dofile("tests/helpers.lua")

-- See https://github.com/echasnovski/mini.nvim/blob/main/lua/mini/test.lua for more documentation

local child = helpers.new_child_neovim()
local eq_global = helpers.expect.global_equality

local T = MiniTest.new_set({
  hooks = {
    -- This will be executed before every (even nested) case
    pre_case = function()
      -- Restart child process with custom 'init.lua' script
      child.restart({ "-u", "scripts/minimal_init.lua" })
      -- the child is started with --noplugin, so source the plugin to get the command
      child.cmd("runtime! plugin/keyseer.lua")
      -- add a nested keymap so the keymap tree has a prefix to descend into
      child.lua([[vim.keymap.set("n", "gxa", "<cmd>echo 'a'<cr>", { desc = "test keymap" })]])
    end,
    -- This will be executed one after all tests from this set are finished
    post_once = child.stop,
  },
})

T["ui"] = MiniTest.new_set()

T["ui"]["catches key presses to navigate the keymap tree"] = function()
  child.cmd("KeySeer")
  -- the home pane registers buffer-local keymaps to catch key presses
  eq_global(child, [[vim.fn.maparg("<BS>", "n", false, true).buffer == 1]], true)
  eq_global(child, [[vim.fn.maparg("<CR>", "n", false, true).buffer == 1]], true)
  -- descend into the 'g' prefix
  child.type_keys("g", "g")
  eq_global(child, [[#require("keyseer.ui").ui.state.keymaps.stack]], 1)
  -- go back up
  child.type_keys("<BS>")
  eq_global(child, [[#require("keyseer.ui").ui.state.keymaps.stack]], 0)
end

T["ui"]["keeps catching key presses after the UI is shown again"] = function()
  child.cmd("KeySeer")
  -- switch to the help pane, then show the UI again while it is open
  child.type_keys("?")
  child.cmd("KeySeer")
  -- the key press keymaps must be registered again
  eq_global(child, [[vim.fn.maparg("<BS>", "n", false, true).buffer == 1]], true)
  eq_global(child, [[vim.fn.maparg("<CR>", "n", false, true).buffer == 1]], true)
  -- descending and going back must still work
  child.type_keys("g", "g")
  eq_global(child, [[#require("keyseer.ui").ui.state.keymaps.stack]], 1)
  child.type_keys("<BS>")
  eq_global(child, [[#require("keyseer.ui").ui.state.keymaps.stack]], 0)
end

T["ui"]["does not duplicate keymaps when the UI is shown again"] = function()
  child.cmd("KeySeer")
  child.cmd("KeySeer")
  eq_global(
    child,
    [[#require("keyseer.ui").ui.state.keymaps.root.children["g"].children["x"].children["a"].keymaps]],
    1
  )
end

return T
