--- This file contains the code for parsing keymaps
local D = require("keyseer.util.debug")
local Utils = require("keyseer.utils")
local config = require("keyseer").config
local Buttons = require("keyseer.util.buttons")
local BuiltInKeyMaps = require("keyseer.util.builtin_keymaps")
local Keypress = require("keyseer.keymaps.keypress")

local if_nil = vim.F.if_nil

-- The Keymaps class does the work of converting the neovim keymaps to keymap layers
---@class Keymaps
---@field root KeyMapTreeNode The root of the keymap treenode
---@field current_node KeyMapTreeNode The current node of the keymap tree
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

  this.current_node = this.root

  return this
end

---Get a tree of keymaps
---@param bufnr buffer? The buffer for which to get keymaps
---@param mode string? Optional mode for which to get keymaps
---@returns table
function Keymaps:get_keymaps(bufnr, mode)
  local mode = mode or config.initial_mode
  local bufnr = bufnr or vim.api.nvim_get_current_buf()
  local global_keymaps = vim.api.nvim_get_keymap(mode)
  local buffer_keymaps = bufnr and vim.api.nvim_buf_get_keymap(bufnr, mode) or {}
  local preset_keymaps = BuiltInKeyMaps[mode]
  self:add_keymaps(preset_keymaps)
  self:add_keymaps(global_keymaps)
  self:add_keymaps(buffer_keymaps)
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
      if string.match(v, "Þ") or string.lower(v) == "<plug>" then
        -- empty out the key_presses table to force the for loop to be skipped
        key_presses = {}
      end
    end

    -- Iterate over the parsed keystr and build the nested keymap
    for depth, key_list in ipairs(key_presses) do
      local modifiers = {}

      for _, key in ipairs(key_list) do
        for k, v in pairs(Keypress.get_modifiers(key)) do
          modifiers[k] = v
        end
        local is_modifier = (
          key == "<Ctrl>"
          or key == "<Meta>"
          or key == "<Shift>"
          or key == "<Alt>"
        )

        if not current_node[key] then
          current_node[key] = { modifiers = {}, children = {}, keymaps = {} }
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

---Get the keycaps at the current node
---@return table<KeyCapTreeNode>
function Keymaps:get_current_keycaps(modifiers)
  vim.validate({ modifiers = { modifiers, "table", true } })
  modifiers =
    vim.tbl_deep_extend("force", { Ctrl = false, Shift = false, Alt = false }, modifiers or {})
  local ret = {}
  for k, v in pairs(self.current_node.children) do
    Utils.notify(k .. " Children: " .. #v.children)
    if #v.children == 0 then
      ret[k] = "KeySeerButtonActive"
    else
      if #v.keymaps > 0 then
        ret[k] = "KeySeerH2"
      end
    end
  end
  return ret
end

return Keymaps
