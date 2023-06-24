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

  -- TODO: Represent modifier toggling in highlights
  include_modifiers = false,

  -- Configuration for keyboard window:
  -- - `height` and `width` are maximum dimensions.
  -- - `border` defines border (as in `nvim_open_win()`).
  window = {
    border = "double", -- none, single, double, shadow
    margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
    winblend = 0, -- value between 0-100 0 for fully opaque and 100 for fully transparent
    show_title = true,
    header_sym = "━",
    title = "keyseer.nvim",
    show_legend = true,
    width = 0.8,
    height = 0.8,
  },

  -- Keyboard options
  keyboard = {
    -- Layout of the keycaps
    layout = "qwerty",
    -- How much space to put around each keycap
    keycap_padding = { 0, 0, 0, 0 },
    -- How much padding to highlight around each keycap
    highlight_padding = { 0, 0, 0, 0 },
    -- override the label used to display some keys.
    key_labels = {
      -- For example:
      -- ["<space>"] = "SPC",
      -- ["<cr>"] = "RET",
      -- ["<tab>"] = "TAB",
    },
  },
}

-- KeySeer functionality ========================================
--

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
    window = { config.window, "table" },
    debug = { config.debug, "boolean" },
    include_modifiers = { config.include_modifiers, "boolean" },
    initial_mode = { config.initial_mode, "string" },
  })

  local is_string_or_array = function(x)
    return type(x) == "string" or vim.tbl_islist(x)
  end

  -- TODO: Add more validations
  vim.validate({
    ["window.border"] = {
      config.window.border,
      is_string_or_array,
      "(keyseer) `config.window.border` can be either string or array.",
    },
    ["window.height"] = { config.window.height, "number" },
    ["window.width"] = { config.window.width, "number" },
  })

  return config
end

H.apply_config = function(config)
  KeySeer.config = config
end

H.show_window = function()
  H.ensure_buffer()

  -- Compute floating window options
  local opts = H.window_options()
  H.open_window(opts)
end

-- Helpers for floating window
H.ensure_buffer = function()
  if H.bufnr then
    return
  end

  H.bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(H.bufnr, "KeySeer")

  vim.api.nvim_buf_set_option(H.bufnr, "bufhidden", "wipe")
  -- buffer is not backed by a file
  vim.api.nvim_buf_set_option(H.bufnr, "buftype", "nofile")
  -- filetype is keyseer
  vim.api.nvim_buf_set_option(H.bufnr, "filetype", "keyseer")
end

return KeySeer
