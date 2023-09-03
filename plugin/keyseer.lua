-- ensure we only create one user command
if _G.KeySeerLoaded then
  return
end

_G.keySeerLoaded = true

vim.api.nvim_create_user_command("KeySeer", function(cmd)
  local args = vim.split(vim.trim(cmd.args), "%s+")
  local mode
  local valid_modes = { "n", "i", "v", "o", "x", "s", "l", "c", "t", "ic" }
  if #args == 1 and args[1] ~= nil and args[1] ~= "" then
    if vim.tbl_contains(valid_modes, args[1]) then
      mode = args[1]
    else
      local Utils = require("keyseer.utils")
      local D = require("keyseer.util.debug")
      D.tprint(args)
      Utils.error("Invalid mode specified. See :map")
      return
    end
  end
  if vim.fn.win_gettype() == "command" then
    error("Can't open keyseer from command-line window. See E11")
    return
  end
  local bufnr = vim.api.nvim_get_current_buf()
  if not vim.g.keyseer then
    require("keyseer").setup()
  end
  mode = vim.F.if_nil(mode, vim.g.keyseer.initial_mode)

  local UI = require("keyseer.ui")
  UI.show("home", mode, bufnr)
end, {
  bar = false,
  bang = false,
  nargs = "?",
  desc = "KeySeer",
})
