-- Simple table of buttons and their inverse
local Buttons = setmetatable({
  unshifted_keys = "1234567890abcdefghijklmnopqrstuvwxyz-=[]\\;',./`",
  shifted_keys = '!@#$%^&*()ABCDEFGHIJKLMNOPQRSTUVWXYZ_+{}|:"<>?~',
}, {
  __newindex = function(t, key, value)
    rawset(t, key, value)
    rawset(t, value, key)
  end,
})

-- Populate the buttons with unshifted and shifted key pairs
for i = 1, #Buttons.unshifted_keys do
  local unshifted_key = Buttons.unshifted_keys:sub(i, i)
  local shifted_key = Buttons.shifted_keys:sub(i, i)
  Buttons[unshifted_key] = shifted_key
end

return Buttons
