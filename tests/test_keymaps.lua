local helpers = dofile("tests/helpers.lua")

-- See https://github.com/echasnovski/mini.nvim/blob/main/lua/mini/test.lua for more documentation

local child = helpers.new_child_neovim()
local eq_global = helpers.expect.global_equality
local eq_type_global = helpers.expect.global_type_equality

local T = MiniTest.new_set({
  hooks = {
    -- This will be executed before every (even nested) case
    pre_case = function()
      -- Restart child process with custom 'init.lua' script
      child.restart({ "-u", "scripts/minimal_init.lua" })
      child.lua([[Keymaps = require("keyseer.keymaps")]])
      child.lua([[Keymaps = require("keyseer.keymaps")]])
      child.lua([[Keypress = require("keyseer.keymaps.keypress")]])
    end,
    -- This will be executed one after all tests from this set are finished
    post_once = child.stop,
  },
})

T["keymaps"] = MiniTest.new_set()
-- Tests related to the new method
T["keymaps"]["exposes public methods"] = function()
  eq_type_global(child, "Keymaps", "table")

  -- public methods
  eq_type_global(child, "Keymaps.new", "function")
end

T["keymaps"]["parses empty keymaps"] = function()
  child.lua([[ret = Keymaps:new()]])
  child.lua([[ret:add_keymaps({})]])
  eq_global(child, "ret.root", { keymaps = {}, modifiers = {}, children = {} })
end

T["keymaps"]["parses simple keymap"] = function()
  child.lua([[ret = Keymaps:new()]])
  child.lua([[ret:add_keymaps({{lhs='g', rhs='g_action'}})]])
  eq_global(child, "ret.root", {
    keymaps = {},
    modifiers = {},
    children = {
      g = {
        keymaps = {
          { lhs = "g", rhs = "g_action" },
        },
        modifiers = {},
        children = {},
        keycode = "g",
      },
    },
  })
end

T["keymaps"]["parses shifted keymap"] = function()
  child.lua([[ret = Keymaps:new()]])
  child.lua([[ret:add_keymaps({{lhs='G', rhs='g_action'}})]])
  eq_global(child, "ret.root", {
    keymaps = {},
    modifiers = {},
    children = {
      G = {
        keymaps = {
          { lhs = "G", rhs = "g_action" },
        },
        modifiers = {
          ["<Shift>"] = true,
        },
        children = {},
        keycode = "G",
      },
    },
  })
end

T["keymaps"]["parses nested keymap"] = function()
  child.lua([[ret = Keymaps:new()]])
  child.lua("ret:add_keymaps({{lhs='gg', rhs='gg_action'}})")
  eq_global(child, "ret.root", {
    keymaps = {},
    modifiers = {},
    children = {
      g = {
        keycode = "g",
        keymaps = {},
        modifiers = {},
        children = {
          g = {
            keymaps = {
              { lhs = "gg", rhs = "gg_action" },
            },
            modifiers = {},
            children = {},
            keycode = "g",
          },
        },
      },
    },
  })
end

T["keymaps"]["parses multiple keymaps"] = function()
  child.lua([[ret = Keymaps:new()]])
  child.lua([[ret:add_keymaps({{lhs='b', rhs='b_action'}, {lhs='g', rhs='g_action'}})]])
  eq_global(child, "ret.root", {
    keymaps = {},
    modifiers = {},
    children = {
      b = {
        keymaps = {
          { lhs = "b", rhs = "b_action" },
        },
        modifiers = {},
        children = {},
        keycode = "b",
      },
      g = {
        keymaps = {
          { lhs = "g", rhs = "g_action" },
        },
        modifiers = {},
        children = {},
        keycode = "g",
      },
    },
  })
end

T["keymaps"]["parses modified keymap"] = function()
  child.lua([[ret = Keymaps:new()]])
  child.lua("ret:add_keymaps({{lhs='<C-g>', rhs='g_action'}})")
  eq_global(child, "ret.root", {
    keymaps = {},
    modifiers = {},
    children = {
      ["<C-g>"] = {
        keymaps = {
          { lhs = "<C-g>", rhs = "g_action" },
        },
        modifiers = {
          ["<Ctrl>"] = true,
        },
        children = {},
        keycode = "g",
      },
    },
  })
end

T["keymaps"]["gets current keycaps"] = function()
  child.lua([[ret = Keymaps:new()]])
  child.lua("ret:add_keymaps({{lhs='g', rhs='g_action'}})")
  eq_global(child, "ret:get_current_keycaps()", {
    g = "KeySeerKeycapKeymap",
  })
  child.lua("ret:add_keymaps({{lhs='<C-g>', rhs='g_action'}})")
  eq_global(child, "ret:get_current_keycaps()", {
    g = "KeySeerKeycapKeymap",
  })
  eq_global(child, "ret:get_current_keycaps({}, {match_modifiers=false})", {
    g = "KeySeerKeycapKeymap",
  })
  eq_global(child, "ret:get_current_keycaps({['<Ctrl>'] = true}, {match_modifiers=true})", {
    g = "KeySeerKeycapKeymap",
    ["<Ctrl>"] = "KeySeerKeycapKeymap",
  })
end

T["keymaps"]["processing keymaps again does not duplicate them"] = function()
  child.lua([[require("keyseer").config.include_builtin_keymaps = false]])
  child.lua([[require("keyseer").config.include_global_keymaps = true]])
  child.lua([[require("keyseer").config.include_buffer_keymaps = false]])
  child.lua([[vim.keymap.set("n", "gxa", "<cmd>echo 'a'<cr>", { desc = "test keymap" })]])
  child.lua([[ret = Keymaps:new()]])
  child.lua([[ret:process_keymaps(nil, "n")]])
  child.lua([[ret:process_keymaps(nil, "n")]])
  eq_global(child, [[#ret.root.children["g"].children["x"].children["a"].keymaps]], 1)
  -- the keycap should not be reported as having multiple keymaps
  child.lua([[ret:push("g")]])
  child.lua([[ret:push("x")]])
  eq_global(child, [=[ret:get_current_keycaps()["a"]]=], "KeySeerKeycapKeymap")
end

T["keymaps"]["processing keymaps again resets the current node"] = function()
  child.lua([[require("keyseer").config.include_builtin_keymaps = false]])
  child.lua([[require("keyseer").config.include_global_keymaps = true]])
  child.lua([[require("keyseer").config.include_buffer_keymaps = false]])
  child.lua([[vim.keymap.set("n", "gxa", "<cmd>echo 'a'<cr>", { desc = "test keymap" })]])
  child.lua([[ret = Keymaps:new()]])
  child.lua([[ret:process_keymaps(nil, "n")]])
  child.lua([[ret:push("g")]])
  child.lua([[ret:process_keymaps(nil, "n")]])
  eq_global(child, [[ret.current_node == ret.root]], true)
  eq_global(child, [[#ret.stack]], 0)
end

T["keymaps"]["matches modifiers"] = function()
  eq_global(child, "Keymaps.matching_keypress({modifiers = {}}, {['<Ctrl>'] = true})", false)
  eq_global(
    child,
    "Keymaps.matching_keypress({modifiers = {['<Ctrl>'] = true}}, {['<Ctrl>'] = false})",
    false
  )
end

T["keymaps"]["matches modifiers truth table"] = function()
  -- entries are { node modifiers, pressed modifiers, expected match }
  local cases = {
    { "{}", "{}", true },
    { "{['<Shift>']=true}", "{['<Shift>']=true}", true },
    { "{}", "{['<Shift>']=true}", false },
    { "{['<Shift>']=true}", "{}", false },
    { "{['<Ctrl>']=true}", "{['<Ctrl>']=true}", true },
    { "{['<Ctrl>']=true}", "{}", false },
    { "{['<Meta>']=true}", "{['<Ctrl>']=true}", false },
    -- shift is ignored when ctrl is held
    { "{['<Ctrl>']=true,['<Shift>']=true}", "{['<Ctrl>']=true}", true },
    { "{['<Ctrl>']=true}", "{['<Ctrl>']=true,['<Shift>']=true}", true },
    { "{['<Ctrl>']=true,['<Shift>']=true}", "{['<Shift>']=true}", false },
    { "{['<Ctrl>']=true,['<Meta>']=true}", "{['<Ctrl>']=true,['<Meta>']=true}", true },
    { "{['<Ctrl>']=true,['<Meta>']=true}", "{['<Ctrl>']=true}", false },
    { "{['<Meta>']=true}", "{['<Meta>']=true}", true },
    -- shift is significant when meta is held
    { "{['<Meta>']=true,['<Shift>']=true}", "{['<Meta>']=true}", false },
    { "{['<Meta>']=true,['<Shift>']=true}", "{['<Meta>']=true,['<Shift>']=true}", true },
  }
  for _, case in ipairs(cases) do
    local node, pressed, expected = case[1], case[2], case[3]
    local expression = ("Keymaps.matching_keypress({modifiers = %s}, %s)"):format(node, pressed)
    eq_global(child, expression, expected)
  end
end

T["keypress"] = MiniTest.new_set()
T["keypress"]["parses unmodified lowercase"] = function()
  eq_global(child, "Keypress.get_modifiers('g')", {})
end
T["keypress"]["parses unmodified uppercase"] = function()
  eq_global(child, "Keypress.get_modifiers('G')", { ["<Shift>"] = true })
  eq_global(child, "Keypress.get_modifiers('L')", { ["<Shift>"] = true })
  eq_global(child, "Keypress.get_modifiers('$')", { ["<Shift>"] = true })
end
T["keypress"]["parses modified lowercase"] = function()
  eq_global(child, "Keypress.get_modifiers('<C-g>')", { ["<Ctrl>"] = true })
end
T["keypress"]["parses modified uppercase"] = function()
  eq_global(child, "Keypress.get_modifiers('<C-G>')", { ["<Ctrl>"] = true, ["<Shift>"] = true })
  eq_global(child, "Keypress.get_modifiers('<C-R>')", { ["<Ctrl>"] = true, ["<Shift>"] = true })
end

T["keypress"]["finds keycodes"] = function()
  eq_global(child, "Keypress.get_keycode('<C-G>')", "G")
  eq_global(child, "Keypress.get_keycode('<C-R>')", "R")
  eq_global(child, "Keypress.get_keycode('R')", "R")
  eq_global(child, "Keypress.get_keycode('<C-Up>')", "Up")
  eq_global(child, "Keypress.get_keycode('<lt>')", "<")
  eq_global(child, "Keypress.get_keycode('<Esc>')", "<Esc>")
  eq_global(child, "Keypress.get_keycode('<F1>')", "<F1>")
  eq_global(child, "Keypress.get_keycode('<F2>')", "<F2>")
  eq_global(child, "Keypress.get_keycode('<CR>')", "<CR>")
  eq_global(child, "Keypress.get_keycode('<Tab>')", "<Tab>")
  eq_global(child, "Keypress.get_keycode('<BS>')", "<BS>")
end

return T
