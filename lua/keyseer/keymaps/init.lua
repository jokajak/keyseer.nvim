--- This file contains the code for parsing keymaps
local BuiltInKeyMaps = require("keyseer.keymaps.builtin_keymaps")
local Buttons = require("keyseer.util.buttons")
local Config = require("keyseer").config
local D = require("keyseer.util.debug")
local Keypress = require("keyseer.keymaps.keypress")
local Utils = require("keyseer.utils")

local if_nil = vim.F.if_nil

---@alias KeySeerModifier "<Ctrl>"|"<Shift>"|"<Meta>"

---Fill in missing modifier keys as not pressed
---@param modifiers table<KeySeerModifier,boolean>|nil
---@return table<KeySeerModifier,boolean>
local function with_default_modifiers(modifiers)
  return vim.tbl_deep_extend(
    "force",
    { ["<Ctrl>"] = false, ["<Shift>"] = false, ["<Meta>"] = false },
    modifiers or {}
  )
end

-- The Keymaps class does the work of converting the neovim keymaps to keymap layers
---@class Keymaps
---@field root KeyMapTreeNode The root of the keymap treenode
---@field current_node KeyMapTreeNode The current node of the keymap tree
---@field stack table<KeyMapTreeNode> The previous node of the keymap tree
local Keymaps = {}
Keymaps.__index = Keymaps

---Create a new keymaps instance
function Keymaps:new()
  local this = setmetatable({
    root = {
      keymaps = {},
      modifiers = {},
      children = {},
    },
  }, self)

  this.stack = {}
  this.current_node = this.root

  return this
end

---Get a tree of keymaps
---@param bufnr buffer? The buffer for which to get keymaps
---@param mode string? Optional mode for which to get keymaps
---@returns table
function Keymaps:process_keymaps(bufnr, mode)
  mode = mode or Config.initial_mode
  -- Rebuild the tree from scratch so that processing keymaps again
  -- (e.g. running :KeySeer while the UI is open) does not insert
  -- duplicate keymaps or leave the current node in a stale tree
  self.root = {
    keymaps = {},
    modifiers = {},
    children = {},
  }
  self.stack = {}
  self.current_node = self.root
  if Config.include_builtin_keymaps then
    local preset_keymaps = BuiltInKeyMaps[mode]
    self:add_keymaps(preset_keymaps)
  end
  if Config.include_global_keymaps then
    local global_keymaps = vim.api.nvim_get_keymap(mode)
    self:add_keymaps(global_keymaps)
  end
  if Config.include_buffer_keymaps then
    local buffer_keymaps = bufnr and vim.api.nvim_buf_get_keymap(bufnr, mode) or {}
    self:add_keymaps(buffer_keymaps)
  end
end

---@class KeySeerKeyMap
---@field lhs string The full lhs of the keymap
---@field rhs string The rhs of the keymap
---@field desc string? The description of the keymap
---@field noremap boolean If the rhs is remappable
---@field silent boolean If the keymap is silent
---@field nowait boolean If the keymap waits for other, longer mappings

---@class KeyMapTreeNode
---@field keymaps table<KeySeerKeyMap>
---@field modifiers table<string,boolean>
---@field children table<KeyMapTreeNode>

-- This class is used to manage displaying the keymaps
---@class KeyCapTreeNode
---@field keymaps table<KeySeerKeyMap>
---@field modifiers table<string,boolean>
---@field children table<KeyCapTreeNode>

--- A function that takes a list of keymaps as input and creates a table with the specified structure.
--- Convert a keymap from lhs = rhs to a KeyMapTreeNode true
---@param keymaps table[]: A list of keymaps.
function Keymaps:add_keymaps(keymaps)
  ---@type KeyMapTreeNode
  local ret = self.root

  for _, keymap in ipairs(keymaps) do
    -- Parse the keystring using Utils.parse_keystring
    local key_presses = Utils.parse_keystring(keymap.lhs, false)
    -- parse_keystring returns a table of tables
    -- each entry in key_presses is a table
    ---@type KeyMapTreeNode
    local current_node = ret["children"]
    local next_node = current_node

    -- Ignore plug keymaps
    for _, v in ipairs(key_presses[1]) do
      -- This is some weird character that shows up
      if string.lower(v) == "<plug>" then
        -- empty out the key_presses table to force the for loop to be skipped
        key_presses = {}
      end
    end
    if string.match(keymap.lhs, "Þ") then
      key_presses = {}
    end

    -- Iterate over the parsed keystr and build the nested keymap
    for depth, key_list in ipairs(key_presses) do
      local modifiers = {}

      for _, key in ipairs(key_list) do
        for k, v in pairs(Keypress.get_modifiers(key)) do
          modifiers[k] = v
        end

        if not current_node[key] then
          current_node[key] = {
            modifiers = {},
            children = {},
            keymaps = {},
            keycode = Keypress.get_keycode(key),
          }
        end
        -- If this is the last key in the sequence, add it to the keymaps entry
        if depth == #key_presses then
          table.insert(current_node[key].keymaps, keymap)
        end
        for modifier, _ in pairs(modifiers) do
          current_node[key].modifiers[modifier] = true
        end
        -- Store the reference for the next node.
        -- This way modifiers could come later
        next_node = current_node[key].children
      end
      -- after processing all keys in the current press, descend down
      current_node = next_node
    end
  end
end

---Reduce a modifier table to its canonical form
---Shift is dropped when Ctrl is held because a Ctrl chord cannot
---distinguish shifted from unshifted keys (<C-a> and <C-A> are the same)
---@param modifiers table<KeySeerModifier,boolean>
---@return string
local function canonical_modifiers(modifiers)
  local shift = modifiers["<Shift>"] and not modifiers["<Ctrl>"]
  return (modifiers["<Ctrl>"] and "C" or "")
    .. (modifiers["<Meta>"] and "M" or "")
    .. (shift and "S" or "")
end

---Return a boolean for whether or not the modifiers match
---@param left table<KeySeerModifier,boolean>
---@param right table<KeySeerModifier,boolean>
local function modifiers_match(left, right)
  return canonical_modifiers(left) == canonical_modifiers(right)
end

---Return a boolean for whether or not the keypress matches the modifiers
---@param node KeyMapTreeNode
---@param modifiers table<string,boolean>
function Keymaps.matching_keypress(node, modifiers)
  vim.validate({ modifiers = { modifiers, "table", true } })

  return modifiers_match(with_default_modifiers(modifiers), with_default_modifiers(node.modifiers))
end

---Get the keycaps at the current node
---@return table<KeyCapTreeNode>
function Keymaps:get_current_keycaps(modifiers, opts)
  vim.validate({ modifiers = { modifiers, "table", true } })
  modifiers = with_default_modifiers(modifiers)
  opts = vim.tbl_deep_extend(
    "force",
    { ["add_modifiers"] = false, ["match_modifiers"] = true },
    opts or {}
  )

  local ret = {}
  for modifier, pressed in pairs(modifiers) do
    if pressed then
      ret[modifier] = "KeySeerKeycapKeymap"
    end
  end

  local matching_keypresses = {}
  -- find matching keypresses
  for keypress, node in pairs(self.current_node.children) do
    local add_keypress = true
    if opts.match_modifiers then
      add_keypress = Keymaps.matching_keypress(node, modifiers)
    end
    if add_keypress then
      if not node.keycode then
        Utils.notify(string.format("No keycode found for %s", keypress), { level = vim.log.WARN })
      else
        D.log("Keymaps", "Adding highlight for %s (%s)", keypress, node.keycode or "?")
        if
          modifiers["<Ctrl>"]
          and not modifiers["<Shift>"]
          and Buttons.shifted_keys:find(node.keycode, 0, true)
        then
          local keycap = Buttons[node.keycode] or node.keycode
          matching_keypresses[keycap] = node
        else
          matching_keypresses[node.keycode] = node
        end
      end
    end
  end

  for k, v in pairs(matching_keypresses) do
    -- empty children means it has a keymap
    if vim.tbl_isempty(v.children) then
      ret[k] = "KeySeerKeycapKeymap"
      if vim.tbl_count(v.keymaps) > 1 then
        ret[k] = "KeySeerKeycapMultipleKeymaps"
      end
    else
      if vim.tbl_count(v.keymaps) == 1 then
        ret[k] = "KeySeerKeycapKeymapAndPrefix"
      elseif vim.tbl_count(v.keymaps) > 1 then
        ret[k] = "KeySeerKeycapKeymapsAndPrefix"
      else
        ret[k] = "KeySeerKeycapPrefix"
      end
    end
  end
  return ret
end

---Get the key presses for the current node
---@return table<KeyCapTreeNode>
function Keymaps:get_current_keypresses()
  local ret = {}
  for keypress, node in pairs(self.current_node.children) do
    if next(node.children) ~= nil then
      table.insert(ret, keypress)
    end
  end
  return ret
end

---Update the current node
function Keymaps:push(keypress)
  if vim.tbl_isempty(self.current_node.children) then
    Utils.notify("Received a keypress for no children.", { level = vim.log.levels.ERROR })
    return
  end
  if self.current_node.children[keypress] ~= nil then
    table.insert(self.stack, self.current_node)
    self.current_node = self.current_node.children[keypress]
  else
    Utils.notify(
      "Received a keypress that isn't valid: " .. keypress,
      { level = vim.log.levels.ERROR }
    )
  end
end

function Keymaps:pop()
  self.current_node = if_nil(table.remove(self.stack), self.root)
end

---Populate keymap statistics in a display
---@param ui KeySeerUI The UI to display to
function Keymaps:add_stats(ui)
  local display = ui.render
  display:append("Keys: ", "", { indent = 2 })
  display:append("X/Y")

  display:append("Shift+Key: ", "", { indent = 2 })
  display:append("X/Y")

  display:append("Ctrl+Key: ", "", { indent = 2 })
  display:append("X/Y")

  display:append("Meta+Key: ", "", { indent = 2 })
  display:append("X/Y"):nl()

  display:append("Shift+Meta+Key: ")
  display:append("X/Y"):nl()
end

---Return the list of keymaps for the keycode provided
---@param keycode string The keycode of the button
---@param modifiers table<string,boolean> The modifier states
function Keymaps:get_keymaps(keycode, modifiers)
  vim.validate({ modifiers = { modifiers, "table", true } })
  modifiers = with_default_modifiers(modifiers)

  local ret = nil
  for _, node in pairs(self.current_node.children) do
    local node_modifiers = with_default_modifiers(node.modifiers)

    local matches = node.keycode == keycode
    if modifiers["<Ctrl>"] and not matches then
      -- search for shifted keys too
      if Buttons.shifted_keys:find(node.keycode, 0, true) then
        -- shift button must be pressed, so look up the button associated with the shifted button
        local unshifted_keycode = Buttons[node.keycode]
        matches = keycode == unshifted_keycode
      end
    end

    if matches then
      matches = modifiers_match(modifiers, node_modifiers)
    end

    if matches then
      if not ret then
        ret = node.keymaps
      else
        Utils.notify(
          string.format("Found more than one keymap node for %s", keycode),
          { level = vim.log.levels.ERROR }
        )
      end
    end
  end
  return ret
end

return Keymaps
