local config = require("shared/config")
GlobalState:set("status", config.status, true)

---@param resource string
local function onResourceStop(resource)
    if resource == cache.resource then
        GlobalState:set("status", nil, true)
    end
end

AddEventHandler("onResourceStop", onResourceStop)
AddEventHandler("onServerResourceStop", onResourceStop)