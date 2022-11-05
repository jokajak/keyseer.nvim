local Util = require("keymaster.util")

local M = {}

---@param options? Options
function M.setup(options)
  require("keymaster.config").setup(options)
end

function M.show(opts)
  opts = opts or {}
  if type(opts) == "string" then
    opts = { mode = opts }
  end

  opts.mode = opts.mode or Util.get_mode()

  -- trigger displaying
  require("keymaster.display").open(opts)
end

function M.reset()
  require("plenary.reload").reload_module("keymaster")
  require("keymaster").setup()
end

return M
