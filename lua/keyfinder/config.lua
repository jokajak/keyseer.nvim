local Keyfinder = {}

--- Your plugin configuration with its default values.
---
--- Default values:
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section)
Keyfinder.options = {
  -- Prints useful logs about what event are triggered, and reasons actions are executed.
  debug = false,
  -- Initial neovim mode to display keybindings
  initial_mode = "n",

  -- TODO: Represent modifier toggling in highlights
  -- include_modifiers = false,

  -- Options for the popup window
  window = {
    border = "double", -- none, single, double, shadow
    margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
    winblend = 0, -- value between 0-100 0 for fully opaque and 100 for fully transparent
    show_title = true,
    header_sym = "━",
    title = "keyfinder.nvim",
    show_legend = true,
    width = 0.8,
    height = 0.8,
  },
  -- Keyboard options
  keyboard = {
    layout = "qwerty",
    padding = { 0, 0, 0, 0 },
    highlight_padding = { 0, 0, 0, 0 },
    key_labels = {
      -- override the label used to display some keys.
      -- For example:
      -- ["<space>"] = "SPC",
      -- ["<cr>"] = "RET",
      -- ["<tab>"] = "TAB",
    },
  },
}

--- Define your keyfinder setup.
---
---@param options table Module config table. See |Keyfinder.options|.
---
---@usage `require("keyfinder").setup()` (add `{}` with your |Keyfinder.options| table)
function Keyfinder.setup(options)
  options = options or {}

  Keyfinder.options = vim.tbl_deep_extend("keep", options, Keyfinder.options)

  return Keyfinder.options
end

return Keyfinder
