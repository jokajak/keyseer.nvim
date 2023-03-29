local M = require("keyfinder.main")
local Keyfinder = {}

-- Toggle the plugin by calling the `enable`/`disable` methods respectively.
function Keyfinder.toggle()
    -- when the config is not set to the global object, we set it
    if _G.Keyfinder.config == nil then
        _G.Keyfinder.config = require("keyfinder.config").options
    end

    _G.Keyfinder.state = M.toggle()
end

-- starts Keyfinder and set internal functions and state.
function Keyfinder.enable()
    if _G.Keyfinder.config == nil then
        _G.Keyfinder.config = require("keyfinder.config").options
    end

    local state = M.enable()

    if state ~= nil then
        _G.Keyfinder.state = state
    end

    return state
end

-- disables Keyfinder and reset internal functions and state.
function Keyfinder.disable()
    _G.Keyfinder.state = M.disable()
end

-- setup Keyfinder options and merge them with user provided ones.
function Keyfinder.setup(opts)
    _G.Keyfinder.config = require("keyfinder.config").setup(opts)
end

_G.Keyfinder = Keyfinder

return _G.Keyfinder
