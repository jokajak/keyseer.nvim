-- You can use this loaded variable to enable conditional parts of your plugin.
if _G.KeyfinderLoaded then
    return
end

_G.KeyfinderLoaded = true

vim.api.nvim_create_user_command("Keyfinder", function()
    require("keyfinder").toggle()
end, {})
