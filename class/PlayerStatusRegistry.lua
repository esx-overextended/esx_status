---@class PlayerStatusRegistry
---@field count number
---@field registry table<string, PlayerStatus>
local PlayerStatusRegistry = {}
PlayerStatusRegistry.__index = PlayerStatusRegistry

setmetatable(PlayerStatusRegistry, {
    __index = PlayerStatusRegistry,
    __metatable = false
})

local DEBUG        = require("shared.config").debug
local PlayerStatus = require("class.PlayerStatus")

---@return number
function PlayerStatusRegistry:getCount()
    return self.count
end

---@param playerId number
---@param restoredStatuses table<string, number>
---@return boolean
function PlayerStatusRegistry:addPlayer(playerId, restoredStatuses)
    if self.registry[playerId] then
        ESX.Trace(("PlayerStatusRegistry:addPlayer(%s) error registry already exist!"):format(playerId), "error", true)

        return false
    end

    if type(playerId) ~= "number" or type(restoredStatuses) ~= "table" then
        ESX.Trace(("PlayerStatusRegistry:addPlayer(%s) error type!"):format(playerId), "error", true)

        return false
    end

    local instance = PlayerStatus(playerId, restoredStatuses)

    if instance then
        self.count += 1
        self.registry[playerId] = instance
    end

    if DEBUG then
        ESX.Trace(("PlayerStatusRegistry:addPlayer(%s) was %s"):format(playerId, instance and "successful" or "unsuccessful"), "trace", true)
    end

    return instance and true or false
end

---@param playerId number
---@return boolean
function PlayerStatusRegistry:removePlayer(playerId)
    if not self.registry[playerId] then
        ESX.Trace(("PlayerStatusRegistry:removePlayer(%s) error registry does not exist!"):format(playerId), "error", true)

        return false
    end

    if type(playerId) ~= "number" then
        ESX.Trace(("PlayerStatusRegistry:removePlayer(%s) error type!"):format(playerId), "error", true)

        return false
    end

    self.registry[playerId]:unregisterAllStatus()

    self.count -= 1
    self.registry[playerId] = nil

    if DEBUG then
        ESX.Trace(("PlayerStatusRegistry:removePlayer(%s) was successful"):format(playerId), "trace", true)
    end

    return true
end

---@param playerId number
---@return PlayerStatus?
function PlayerStatusRegistry:getPlayer(playerId)
    if not self.registry[playerId] then
        if DEBUG then
            ESX.Trace(("PlayerStatusRegistry:getPlayer(%s) error registry does not exist!"):format(playerId), "trace", true)
        end

        return
    end

    return self.registry[playerId]
end

---@return PlayerStatusRegistry
return function()
    return setmetatable({
        count = 0,
        registry = {},
    }, PlayerStatusRegistry)
end
