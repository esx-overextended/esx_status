---@class PlayerStatusRegistry
---@field count number
---@field registry table<string, PlayerStatus>
local PlayerStatusRegistry = {}
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
        if DEBUG then
            ESX.Trace("PlayerStatusRegistry:addPlayer error registry already exist!", "error", true)
        end

        return false
    end

    if type(playerId) ~= "number" or type(restoredStatuses) ~= "table" then
        if DEBUG then
            ESX.Trace("PlayerStatusRegistry:addPlayer error type!", "error", true)
        end

        return false
    end

    local instance = PlayerStatus(playerId, restoredStatuses)

    if instance then
        self.count += 1
        self.registry[playerId] = instance
    end

    return instance and true or false
end

---@param playerId number
---@return boolean
function PlayerStatusRegistry:removePlayer(playerId)
    if not self.registry[playerId] then
        if DEBUG then
            ESX.Trace("PlayerStatusRegistry:removePlayer error registry does not exist!", "error", true)
        end

        return false
    end

    if type(playerId) ~= "number" then
        if DEBUG then
            ESX.Trace("PlayerStatusRegistry:removePlayer error type!", "error", true)
        end

        return false
    end

    self.registry[playerId]:unregisterAllStatus()

    self.count -= 1
    self.registry[playerId] = nil


    return true
end

---@param playerId number
---@return PlayerStatus?
function PlayerStatusRegistry:getPlayer(playerId)
    if not self.registry[playerId] then
        if DEBUG then
            ESX.Trace("PlayerStatusRegistry:getPlayer error registry does not exist!", "error", true)
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
