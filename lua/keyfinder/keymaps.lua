--- This file contains the code for parsing keymaps
local D = require("keyfinder.util.debug")
local Utils = require("keyfinder.utils")
local config = require("keyfinder.config")
local Buttons = require("keyfinder.util.buttons")

local if_nil = vim.F.if_nil

--- A function that takes a list of keymaps as input and creates a table with the specified structure.
-- @param keymaps table[]: A list of keymaps.
-- @return table: The generated table with keys as the first character of lhs and values as tables with keys 'keymaps' and 'children'.
local function parse_keymaps(keymaps)
  local ret = {}

  ---Populate the current_node from the key presses
  ---@param current_node table The current keymap tree node
  ---@param key_presses table The list of keys being pressed
  local function populate_node(current_node, key_presses)
    local modifiers = {}
  end
  for _, keymap in ipairs(keymaps) do
    -- Parse the keystring using Utils.parse_keystring
    local key_presses = Utils.parse_keystring(keymap.lhs)
    local current_node = ret
    local next_node = current_node

    -- Ignore plug keymaps
    if key_presses[1]:lower() == "<plug>" then
      -- empty out the key_presses table to force the for loop to be skipped
      key_presses = {}
    end

    -- Iterate over the parsed keystr and build the nested keymap
    for depth, key_list in ipairs(key_presses) do
      local modifiers = {}

      for _, key in ipairs(key_list) do
        local is_modifier = (
          key == "<Ctrl>"
          or key == "<Meta>"
          or key == "<Shift>"
          or key == "<Alt>"
        )

        if is_modifier then
          modifiers[key] = true
        else
          if Buttons.shifted_keys:find(key, 0, true) then
            -- shift button is currently pressed
            modifiers["<Shift>"] = true
          end
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
      end
      -- after processing all keys in the current press, descend down
      current_node = next_node
    end
  end
  return ret
end

---@class KeymapLayer
---@field normal table The neovim keymaps with no modifiers
---@field shifted table The neovim keymaps with the shift key held down
---@field meta table The neovim keymaps with the meta key held down
---@field ctrl table The neovim keymaps with the ctrl key held down

---@class KeymapTreeNode
---@field children KeymapTreeNode[] The list of child keymaps
---@field layers KeymapLayer Information about the keymap layers

-- The Keymaps class does the work of converting the neovim keymaps to keymap layers
---@class Keymaps
---@field mode string The neovim mode for keymappings
---@field prefix table The table of prefix characters
---@field current_node KeymapTree The current node in the keymap tree
local Keymaps = {}
Keymaps.__index = Keymaps

---Create a new keymaps instance
---@param opts table options
function Keymaps:new(opts)
  opts = opts or {}

  local obj = setmetatable({
    mode = if_nil(opts.mode, config.options.initial_mode),
    prefix = if_nil(opts.prefix, {}),
    bufnr = if_nil(opts.bufnr, vim.api.nvim_get_current_buf()),
    _original_mode = vim.api.nvim_get_mode().mode,
  }, self)

  return obj
end

return Keymaps
