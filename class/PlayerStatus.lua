---@class PlayerStatus
---@field playerId number
---@field statuses table<string, Status>
---@field statebag { set: fun(self: any, bagName: string, value: any, replicated?: boolean), [string]: any }
local PlayerStatus = {}
PlayerStatus.__index = PlayerStatus

setmetatable(PlayerStatus, {
    __index = PlayerStatus,
    __metatable = false
})

local Status   = require("class.Status")
local DEBUG    = require("shared.config").debug
local statuses = require("shared.config").statuses --[[@as table<string, StatusConfig>]]

---@param name string
---@param value number | string | boolean
---@return boolean
function PlayerStatus:registerStatus(name, value)
    if self.statuses[name] then
        ESX.Trace(("PlayerStatus:registerStatus(%s) for player id %s error status already exist!"):format(name, self.playerId), "error", true)

        return false
    end

    local instance = Status(name, value)

    if instance then
        self.statuses[name] = instance
        self.statebag:set(name, value, true)
    end

    if DEBUG then
        ESX.Trace(("PlayerStatus:registerStatus(%s, %s) for player id %s was %s"):format(name, value, self.playerId, instance and "^2successful^7" or "^1unsuccessful^7"), "trace", true)
    end

    return instance and true or false
end

---@param name string
---@return boolean
function PlayerStatus:unregisterStatus(name)
    if not self.statuses[name] then
        ESX.Trace(("PlayerStatus:unregisterStatus(%s) for player id %s error status does not exist!"):format(name, self.playerId), "error", true)

        return false
    end

    self.statuses[name] = nil
    self.statebag:set(name, nil, true)

    if DEBUG then
        ESX.Trace(("PlayerStatus:unregisterStatus(%s) for player id %s was successful"):format(name, self.playerId), "trace", true)
    end

    return true
end

function PlayerStatus:unregisterAllStatus()
    for status in pairs(self.statuses) do
        self:unregisterStatus(status)
    end
end

---@param name string
---@return number | string | boolean | nil
function PlayerStatus:getStatus(name)
    local status = self.statuses[name]

    if not status then
        if DEBUG then
            ESX.Trace(("PlayerStatus:getStatus(%s) for player id %s error registry does not exist!"):format(name, self.playerId), "trace", true)
        end

        return
    end

    return status and status:getValue()
end

---@return table<string, number | string | boolean>
function PlayerStatus:getAllStatus()
    local playerStatuses = {}

    for statusName, statusData in pairs(self.statuses) do
        playerStatuses[statusName] = statusData:getValue()
    end

    return playerStatuses
end

---@param name string
---@param value number | string | boolean
---@return boolean
function PlayerStatus:setStatus(name, value)
    local status = self.statuses[name]

    if not status then
        if DEBUG then
            ESX.Trace(("PlayerStatus:setStatus(%s) for player id %s error registry does not exist!"):format(name, self.playerId), "trace", true)
        end

        return false
    end

    local isSuccessful = status:setValue(value)

    if isSuccessful then
        self.statebag:set(name, value, true)
    end

    return isSuccessful
end

---@param name string
---@param value number
---@return boolean
function PlayerStatus:increaseStatus(name, value)
    local status = self.statuses[name]

    if not status then
        if DEBUG then
            ESX.Trace(("PlayerStatus:increaseStatus(%s) for player id %s error registry does not exist!"):format(name, self.playerId), "trace", true)
        end

        return false
    end

    local receivedType = type(value)
    local expectedType = type(statuses[name]?.value)

    if expectedType ~= "number" or receivedType ~= "number" then return false end

    local potentialValueAfterUpdate = status:getValue() + value

    if statuses[name].min and potentialValueAfterUpdate < statuses[name].min then
        potentialValueAfterUpdate = statuses[name].min
    elseif statuses[name].max and potentialValueAfterUpdate > statuses[name].max then
        potentialValueAfterUpdate = statuses[name].max
    end

    ---@cast potentialValueAfterUpdate -?
    local isSuccessful = status:setValue(potentialValueAfterUpdate)

    if isSuccessful then
        self.statebag:set(name, potentialValueAfterUpdate, true)
    end

    return isSuccessful
end

---@param name string
---@param value number
---@return boolean
function PlayerStatus:decreaseStatus(name, value)
    local status = self.statuses[name]

    if not status then
        if DEBUG then
            ESX.Trace(("PlayerStatus:decreaseStatus(%s) for player id %s error registry does not exist!"):format(name, self.playerId), "trace", true)
        end

        return false
    end

    local receivedType = type(value)
    local expectedType = type(statuses[name]?.value)

    if expectedType ~= "number" or receivedType ~= "number" then return false end

    local potentialValueAfterUpdate = status:getValue() - value

    if statuses[name].min and potentialValueAfterUpdate < statuses[name].min then
        potentialValueAfterUpdate = statuses[name].min
    elseif statuses[name].max and potentialValueAfterUpdate > statuses[name].max then
        potentialValueAfterUpdate = statuses[name].max
    end

    ---@cast potentialValueAfterUpdate -?
    local isSuccessful = status:setValue(potentialValueAfterUpdate)

    if isSuccessful then
        self.statebag:set(name, potentialValueAfterUpdate, true)
    end

    return isSuccessful
end

AddStateBagChangeHandler("statuses", "global", function(_, _, value)
    if not value then return end

    ---@cast value table<string, StatusConfig>

    statuses = value
end)

---@param playerId number
---@param restoredStatuses table<string, number | string | boolean>
---@return PlayerStatus?
return function(playerId, restoredStatuses)
    local typePlayerId = type(playerId)
    local typeRestoredStatuses = type(restoredStatuses)

    if typePlayerId ~= "number" then
        return ESX.Trace(("Invalid playerId passed while creating an instance of PlayerStatus class! Expected ^2'number'^7, Received ^1'%s'^7"):format(typePlayerId), "error", true)
    end

    if typeRestoredStatuses ~= "table" then
        return ESX.Trace(("Invalid restoredStatuses passed while creating an instance of PlayerStatus class! Expected ^2'table'^7, Received ^1'%s'^7"):format(typeRestoredStatuses), "error", true)
    end

    local self = setmetatable({
        statuses = {},
        playerId = playerId,
        statebag = Player(playerId).state
    }, PlayerStatus)

    for statusName, statusConfig in pairs(statuses) do
        self:registerStatus(statusName, restoredStatuses?[statusName] or statusConfig.value)
    end

    return self
end
