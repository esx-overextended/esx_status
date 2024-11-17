local utils  = require("shared.utils")
local config = require("shared.config")

AddStateBagChangeHandler("statuses", "global", function(_, _, value)
    if not value then return end

    ---@cast value table<string, StatusConfig>

    config.statuses = value
end)

-----------------------------------------
-----------------EXPORTS-----------------
-----------------------------------------

---Generates an export to get the specified registered status in the system
---@param statusName string
---@return StatusConfig?
function utils.api.getGlobalStatus(statusName)
    return config.statuses[statusName]
end

---Generates an export to get all registered statuses in the system
---@return table<string, StatusConfig>
function utils.api.getGlobalStatuses()
    return config.statuses
end

-----------------------------------------
-----------------EXPORTS-----------------
-----------------------------------------
