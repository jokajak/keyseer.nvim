local M = {}

---@param options? Options
function M.setup(options)
  require("keyfinder.config").setup(options)
end

function M.show(opts)
  local Util = require("keyfinder.util")

  opts = opts or {}
  if type(opts) == "string" then
    opts = { mode = opts }
  end

  opts.mode = opts.mode or Util.get_mode()
  opts.prefix = opts.prefix or ""
  opts.prefix = string.gsub(opts.prefix, "<leader>", vim.g.mapleader)

  -- trigger displaying
  require("keyfinder.display").open(opts)
end

function M.reset()
  require("plenary.reload").reload_module("keyfinder")
  require("keyfinder").setup()
end

return M
