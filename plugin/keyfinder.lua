if _G.KeySeer then
  return
end

_G.KeySeer = true

vim.api.nvim_create_user_command("KeySeer", function()
  require("keyseer").toggle()
end, {})
