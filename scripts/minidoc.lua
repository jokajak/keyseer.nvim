local minidoc = require("mini.doc")

if _G.MiniDoc == nil then
  minidoc.setup()
end

local modules = {
  "ui",
}

minidoc.generate({ "lua/keyseer/init.lua" }, "doc/keyseer.txt")

for _, m in ipairs(modules) do
  minidoc.generate({ "lua/keyseer/" .. m .. ".lua" }, "doc/keyseer-" .. m .. ".txt")
end
