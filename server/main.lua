local utils  = require("shared.utils")
local config = require("shared.config")
GlobalState:set("statuses", config.statuses, true)

local tracker = require("class.PlayerStatusRegistry")()

AddEventHandler("esx:playerLoaded", function(playerId, xPlayer)
    if tracker:addPlayer(playerId, xPlayer.metadata.statuses) then
        TriggerEvent("esx_status:playerAdded", playerId)
        Entity(playerId).state:set("esx_status:loaded", true, true)
    end
end)

AddEventHandler("esx:playerDropped", function(playerId)
    if tracker:removePlayer(playerId) then
        TriggerEvent("esx_status:playerRemoved", playerId)
        Entity(playerId).state:set("esx_status:loaded", false, true)
    end
end)

---Generates an export to retrieve the specified player's status value
---@param playerId number
---@param status string
---@return number?
function utils.api.getPlayerStatus(playerId, status)
    local player = tracker:getPlayer(playerId)
    local playerStatus = player and player:getStatus(status)

    return playerStatus and playerStatus:getValue()
end

---Generates an export to set the specified player's status value
---@param playerId number
---@param status string
---@param amount number
---@return boolean?
function utils.api.setPlayerStatus(playerId, status, amount)
    local player = tracker:getPlayer(playerId)
    local playerStatus = player and player:getStatus(status)

    return playerStatus and playerStatus:setValue(amount)
end

---Generates an export to increase the specified player's status value
---@param playerId number
---@param status string
---@param amount number
---@return boolean?
function utils.api.increasePlayerStatus(playerId, status, amount)
    local player = tracker:getPlayer(playerId)
    local playerStatus = player and player:getStatus(status)

    return playerStatus and playerStatus:increaseValue(amount)
end

---Generates an export to decrease the specified player's status value
---@param playerId number
---@param status string
---@param amount number
---@return boolean?
function utils.api.decreasePlayerStatus(playerId, status, amount)
    local player = tracker:getPlayer(playerId)
    local playerStatus = player and player:getStatus(status)

    return playerStatus and playerStatus:decreaseValue(amount)
end

---@param resource string
local function onResourceStop(resource)
    if resource == cache.resource then
        GlobalState:set("statuses", nil, true)
    end
end

AddEventHandler("onResourceStop", onResourceStop)
AddEventHandler("onServerResourceStop", onResourceStop)
