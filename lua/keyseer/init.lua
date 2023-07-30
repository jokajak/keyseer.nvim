--- *KeySeer* See your keys and their keymaps

local KeySeer = {}
local H = {}

--- Plugin setup
---
---@param config table|nil Module config table. See |KeySeer.config|.
---
---@usage `require('keyseer').setup({})` (replace `{}` with your `config` table)
KeySeer.setup = function(config)
  -- Export the plugin
  _G.KeySeer = KeySeer

  -- Setup the configuration
  config = H.setup_config(config)

  -- Apply the configuration
  H.apply_config(config)

  KeySeer.ns = vim.api.nvim_create_namespace("keyseer")

  ---@return string, string[]
  local function parse(args)
    local parts = vim.split(vim.trim(args), "%s+")
    if parts[1]:find("KeySeer") then
      table.remove(parts, 1)
    end
    if args:sub(-1) == " " then
      parts[#parts + 1] = ""
    end
    return table.remove(parts, 1) or "", parts
  end

  vim.api.nvim_create_user_command("KeySeer", function(cmd)
    local prefix, args = parse(cmd.args)
    local mode
    if #args == 1 and args[1] == "n" then
      mode = "n"
    end
    if vim.fn.win_gettype() == "command" then
      error("Can't open keyseer from command-line window. See E11")
      return
    end
    local bufnr = vim.api.nvim_get_current_buf()

    local UI = require("keyseer.ui")
    UI.show("home", mode, bufnr)
  end, {
    bar = false,
    bang = false,
    nargs = "?",
    desc = "KeySeer",
  })
end

--- KeySeer Config
---
--- Default values:
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section)
KeySeer.config = {
  -- Prints useful logs about what event are triggered, and reasons actions are executed.
  debug = false,
  -- Initial neovim mode to display keybindings
  initial_mode = "n",

  include_modifiers = true,
  -- Boolean to include built in keymaps in display
  include_builtin_keymaps = false,
  -- Boolean to include global keymaps in display
  include_global_keymaps = true,
  -- Boolean to include buffer keymaps in display
  include_buffer_keymaps = true,
  -- TODO: Represent modifier toggling in highlights
  -- Boolean to include modified keys (e.g. <C-x> or <A-y> or C) in display
  include_modified_keypresses = false,

  -- Configuration for ui:
  -- - `border` defines border (as in `nvim_open_win()`).
  ui = {
    border = "double", -- none, single, double, shadow
    margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
    winblend = 0, -- value between 0-100 0 for fully opaque and 100 for fully transparent
    size = {
      width = 65,
      height = 10,
    },
    icons = {
      keyseer = "",
    },
    show_header = true, -- boolean if the header should be shown
  },

  -- Keyboard options
  keyboard = {
    -- Layout of the keycaps
    ---@type string|Keyboard
    layout = "qwerty",
    keycap_padding = { 0, 1, 0, 1 }, -- padding around keycap labels [top, right, bottom, left]
    -- How much padding to highlight around each keycap
    highlight_padding = { 0, 0, 0, 0 },
    -- override the label used to display some keys.
    key_labels = {
      ["Up"] = "↑",
      ["Down"] = "↓",
      ["Left"] = "←",
      ["Right"] = "→",
      ["<F1>"] = "F1",
      ["<F2>"] = "F2",
      ["<F3>"] = "F3",
      ["<F4>"] = "F4",
      ["<F5>"] = "F5",
      ["<F6>"] = "F6",
      ["<F7>"] = "F7",
      ["<F8>"] = "F8",
      ["<F9>"] = "F9",
      ["<F10>"] = "F10",

      -- For example:
      -- ["<space>"] = "SPC",
      -- ["<cr>"] = "RET",
      -- ["<tab>"] = "TAB",
    },
  },
}

-- KeySeer functionality ========================================
--
---Open the keyseer ui
---@param mode? string the neovim mode to show keymaps for
---@param bufnr? buffer the buffer for buffer specific keymaps
KeySeer.show = function(mode, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  mode = mode or "n"

  local UI = require("keyseer.ui")
  UI.show("home", mode, bufnr)
end

KeySeer.close = function()
  local UI = require("keyseer.ui")
  UI:close()
end

-- Helper data ================================================================
-- Module default config
H.default_config = KeySeer.config

-- Helper functionality ========================================
-- Settings
H.setup_config = function(config)
  -- General idea: if some table elements are not present in user-supplied
  -- `config`, take them from default config
  vim.validate({ config = { config, "table", true } })
  config = vim.tbl_deep_extend("force", H.default_config, config or {})

  -- Validate per nesting level to produce correct error message
  vim.validate({
    keyboard = { config.keyboard, "table" },
    ui = { config.ui, "table" },
    debug = { config.debug, "boolean" },
    include_modifiers = { config.include_modifiers, "boolean" },
    initial_mode = { config.initial_mode, "string" },
  })

  local is_string_or_array = function(x)
    return type(x) == "string" or vim.tbl_islist(x)
  end

  -- TODO: Add more validations
  vim.validate({
    ["ui.border"] = {
      config.ui.border,
      is_string_or_array,
      "(keyseer) `config.ui.border` can be either string or array.",
    },
    ["ui.size"] = { config.ui.size, "table" },
  })
  vim.validate({
    ["ui.size.height"] = { config.ui.size.height, "number" },
    ["ui.size.width"] = { config.ui.size.width, "number" },
  })

  return config
end

H.apply_config = function(config)
  KeySeer.config = config
end

return KeySeer
