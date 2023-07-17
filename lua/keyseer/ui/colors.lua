-- Copied from https://github.com/folke/lazy.nvim/blob/b7043f2983d7aead78ca902f3f2053907081859a/lua/lazy/view/colors.lua
local M = {}

M.colors = {
  H1 = "IncSearch", -- home button
  H2 = "Bold", -- titles
  Comment = "Comment",
  Normal = "NormalFloat",
  Dimmed = "Conceal", -- property
  Prop = "Conceal", -- property
  Value = "@string", -- value of a property
  Special = "@punctuation.special",
  Button = "CursorLine",
  ButtonActive = "Visual",
}

---@type table<string,table>
M.keycap_colors = {
  -- KeycapKeymap = { link = "CursorLine", default = true },
  -- KeycapMultipleKeymaps = { link = "Conceal", default = true },
  -- KeycapKeymapAndPrefix = { link = "Visual", default = true },
  -- KeycapKeymapsAndPrefix = { link = "IncSearch", default = true },
  -- KeycapPrefix = { link = "NormalFloat", default = true },
  -- KeycapKeymap = { default = true, fg = "#d65d0e", ctermfg = "White" },
  -- KeycapMultipleKeymaps = { default = true, fg = "#d79921", ctermfg = "Yellow" },
  -- KeycapKeymapAndPrefix = { default = true, fg = "#a89984", ctermfg = "Cyan" },
  -- KeycapKeymapsAndPrefix = { default = true, fg = "#cc241d", ctermfg = "Red" },
  -- KeycapPrefix = { default = true, fg = "#458588", ctermfg = "Blue" },
  KeycapKeymap = { default = true, bg = "#d65d0e", ctermbg = "White" },
  KeycapMultipleKeymaps = { default = true, bg = "#d79921", ctermbg = "Yellow" },
  KeycapKeymapAndPrefix = { default = true, bg = "#a89984", ctermbg = "Cyan" },
  KeycapKeymapsAndPrefix = { default = true, bg = "#cc241d", ctermbg = "Red" },
  KeycapPrefix = { default = true, bg = "#458588", ctermbg = "Blue" },
}

M.did_setup = false

function M.set_hl()
  for hl_group, link in pairs(M.colors) do
    vim.api.nvim_set_hl(0, "KeySeer" .. hl_group, { link = link, default = true })
  end
  for hl_group, opts in pairs(M.keycap_colors) do
    vim.api.nvim_set_hl(0, "KeySeer" .. hl_group, opts)
  end
end

function M.setup()
  if M.did_setup then
    return
  end

  M.did_setup = true

  M.set_hl()
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      M.set_hl()
    end,
  })
end

return M
