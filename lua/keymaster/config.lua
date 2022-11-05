local M = {}

M.namespace = vim.api.nvim_create_namespace("Keymaster")

--@class Options
local defaults = {
  key_labels = {
    -- override the label used to display some keys. It doesn't effect KM in any other way.
    -- For example:
    -- ["<space>"] = "SPC",
    -- ["<cr>"] = "RET",
    -- ["<tab>"] = "TAB",
    -- TODO: Support top and bottom
    padding = { 0, 1, 0, 1 }, -- padding around keycap labels [top, right, bottom, left]
  },
  window = {
    border = "double", -- none, single, double, shadow
    margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
    winblend = 0, -- value between 0-100 0 for fully opaque and 100 for fully transparent
    rows = 5,
    columns = 80,
    show_title = true,
    header_sym = "━",
    header_lines = 2,
    title = "keymaster.nvim",
  },
  -- disable the Keymaster popup for certain buf types and file types.
  disable = {
    buftypes = {},
    filetypes = {},
  },
  layout = "qwerty", -- keycap layout, qwerty or dvorak
}

--@type Options
M.options = {}

---@param options? Options
function M.setup(options)
  M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
end

M.setup()

return M
