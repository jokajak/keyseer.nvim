local Keyfinder = {}

--- Your plugin configuration with its default values.
---
--- Default values:
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section)
Keyfinder.options = {
  -- Prints useful logs about what event are triggered, and reasons actions are executed.
  debug = false,
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
