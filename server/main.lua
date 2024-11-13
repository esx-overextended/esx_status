local config = require("shared.config")
GlobalState:set("statuses", config.statuses, true)

---@param resource string
local function onResourceStop(resource)
    if resource == cache.resource then
        GlobalState:set("statuses", nil, true)
    end
end

AddEventHandler("onResourceStop", onResourceStop)
AddEventHandler("onServerResourceStop", onResourceStop)
