-- Copied from https://github.com/folke/lazy.nvim/blob/b7043f2983d7aead78ca902f3f2053907081859a/lua/lazy/view/render.lua
local Text = require("keyseer.ui.text")
local UIConfig = require("keyseer.ui.config")
local Config = require("keyseer").config

---@class KeySeerRender: Text
---@field ui KeySeerUI
---@private
local KeySeerRender = {}

---@return KeySeerRender
---@param ui KeySeerUI
function KeySeerRender.new(ui)
  ---@type KeySeerRender|Text
  local self = setmetatable({}, { __index = setmetatable(KeySeerRender, { __index = Text }) })
  self.ui = ui
  self.padding = 0
  ---@cast self -Text
  return self
end

function KeySeerRender:update()
  self._lines = {}
  self.buttons = {}

  if Config.ui.show_header then
    self:header()
  end

  local pane = self.ui.state.pane

  local available, renderer = pcall(require, "keyseer.ui.panes." .. pane)
  if available then
    renderer.render(self.ui)
  end

  self:trim()
  self:render(self.ui.buf)
end

function KeySeerRender:header()
  self:nl():nl()
  local panes = vim.tbl_filter(function(c)
    return c.button
  end, UIConfig.get_panes())

  for c, pane in ipairs(panes) do
    local title = " " .. pane.name:sub(1, 1):upper() .. pane.name:sub(2) .. " (" .. pane.key .. ") "
    if pane.name == "home" then
      if self.ui.state.pane == "home" then
        title = " keyseer.nvim  " .. Config.ui.icons.keyseer .. "  "
      else
        title = " keyseer.nvim (H) "
      end
    end

    if self.ui.state.pane == pane.name then
      if pane.name == "home" then
        self:append(title, "KeySeerH1")
      else
        self:append(title, "KeySeerButtonActive")
        self:highlight({ ["%(.%)"] = "KeySeerSpecial" })
      end
    else
      self:append(title, "KeySeerButton")
      self:highlight({ ["%(.%)"] = "KeySeerSpecial" })
    end
    if c == #panes then
      break
    end
    self:append(" ")
  end
  self:nl():nl()
end

return KeySeerRender
