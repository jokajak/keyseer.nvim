--- UI Configuration

---@class KeySeerUIPane
---@field id number
---@field button? boolean
---@field desc? string
---@field key? string
---@field toggle? boolean

local M = {}

function M.get_panes()
  ---@type (KeySeerUIPane|{name:string})[]
  local ret = {}
  for k, v in pairs(M.panes) do
    v.name = k
    ret[#ret + 1] = v
  end
  table.sort(ret, function(a, b)
    return a.id < b.id
  end)
  return ret
end

M.keys = {
  back = "<bs>",
  close = "q",
  details = "<cr>",
  go = "g",
}

---@type table<string,KeySeerUIPane>
M.panes = {
  home = {
    button = true,
    id = 1,
    desc = "Go back to main view",
    key = "H",
  },
  details = {
    button = true,
    id = 2,
    desc = "Show details of current key",
    key = "D",
    toggle = true,
  },
  configuration = {
    button = true,
    id = 3,
    desc = "Show configuration options",
    key = "C",
    toggle = true,
  },
  help = {
    button = true,
    id = 4,
    desc = "Show this help page",
    key = "?",
    toggle = true,
  },
}

return M
