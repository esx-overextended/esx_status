---@class PlayerStatus
---@field playerId string
---@field statuses table<string, Status>
local PlayerStatus = {}
setmetatable(PlayerStatus, {
    __index = PlayerStatus,
    __metatable = false
})

local Status = require("class.Status")

---@param name string
---@param value number
---@return boolean
function PlayerStatus:registerStatus(name, value)
    if self.statuses[name] then
        if DEBUG then
            ESX.Trace("PlayerStatus:registerStatus error status already exist!", "error", true)
        end

        return false
    end

    self.statuses[name] = Status(name, value)

    return self.statuses[name] and true
end

---@param playerId number
---@param restoredStatuses table<string, number>
return function(playerId, restoredStatuses)
    local self = setmetatable({
        playerId = playerId,
        statuses = {}
    }, PlayerStatus)

    for statusName, configData in pairs(GlobalState.statuses) do
        self:registerStatus(statusName, restoredStatuses[statusName] or configData.value)
    end

    return self
end
