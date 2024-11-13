---@class PlayerStatus
---@field playerId number
---@field statuses table<string, Status>
---@field statebag { set: fun(self, bagName: string, value: any, replicated?: boolean) }
local PlayerStatus = {}
setmetatable(PlayerStatus, {
    __index = PlayerStatus,
    __metatable = false
})

local Status = require("class.Status")
local DEBUG  = require("shared.config").debug

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

    local instance = Status(name, value)

    if instance then
        self.statuses[name] = instance
        self.statebag:set(name, value, true)
    end

    return instance and true or false
end

---@param name string
---@return boolean
function PlayerStatus:unregisterStatus(name)
    if not self.statuses[name] then
        if DEBUG then
            ESX.Trace("PlayerStatus:unregisterStatus error status does not exist!", "error", true)
        end

        return false
    end

    self.statuses[name] = nil
    self.statebag:set(name, nil, true)

    return true
end

function PlayerStatus:unregisterAllStatus()
    for status in pairs(self.statuses) do
        self:unregisterStatus(status)
    end
end

---@param name string
---@return Status?
function PlayerStatus:getStatus(name)
    if not self.statuses[name] then
        if DEBUG then
            ESX.Trace("PlayerStatus:getStatus error status does not exist!", "error", true)
        end

        return
    end

    return self.statuses[name]
end

---@return table<string, Status>
function PlayerStatus:getAllStatus()
    return self.statuses
end

---@param playerId number
---@param restoredStatuses table<string, number>
return function(playerId, restoredStatuses)
    local self = setmetatable({
        statuses = {},
        playerId = playerId,
        statebag = Entity(playerId).state
    }, PlayerStatus)

    for statusName, configData in pairs(GlobalState.statuses) do
        self:registerStatus(statusName, restoredStatuses?[statusName] or configData.value)
    end

    return self
end
