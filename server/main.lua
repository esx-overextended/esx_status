local utils   = require("shared.utils")
local config  = require("shared.config")
local tracker = require("class.PlayerStatusRegistry")()
local DEBUG   = config.debug

---@param playerId number
---@param xPlayer table
local function onPlayerLoaded(playerId, xPlayer)
    local isSuccessful = tracker:addPlayer(playerId, xPlayer.metadata.statuses or {})

    if isSuccessful then
        TriggerEvent("esx_status:playerAdded", playerId)
        Player(playerId).state:set("esx_status:loaded", true, true)
    end

    if DEBUG then
        ESX.Trace(("Loading of playerId %s into the system was %s"):format(playerId, isSuccessful and "successful" or "unsuccessful"), "trace", true)
    end
end

---@param playerId number
local function onPlayerDropped(playerId)
    local isSuccessful = tracker:removePlayer(playerId)

    if isSuccessful then
        TriggerEvent("esx_status:playerRemoved", playerId)
        Player(playerId).state:set("esx_status:loaded", false, true)
    end

    if DEBUG then
        ESX.Trace(("Removing of playerId %s from the system was %s"):format(playerId, isSuccessful and "successful" or "unsuccessful"), "trace", true)
    end
end

AddEventHandler("esx:playerLoaded", onPlayerLoaded)
AddEventHandler("esx:playerDropped", onPlayerDropped)

---Generates an export to retrieve the specified player's status value
---@param playerId number
---@param status string
---@return number?
function utils.api.getPlayerStatus(playerId, status)
    local player = tracker:getPlayer(playerId)

    return player and player:getStatus(status)
end

---Generates an export to set the specified player's status value
---@param playerId number
---@param status string
---@param amount number
---@return boolean?
function utils.api.setPlayerStatus(playerId, status, amount)
    local player = tracker:getPlayer(playerId)

    return player and player:setStatus(status, amount)
end

---Generates an export to increase the specified player's status value
---@param playerId number
---@param status string
---@param amount number
---@return boolean?
function utils.api.increasePlayerStatus(playerId, status, amount)
    local player = tracker:getPlayer(playerId)

    return player and player:setStatus(status, player:getStatus(status) + amount)
end

---Generates an export to decrease the specified player's status value
---@param playerId number
---@param status string
---@param amount number
---@return boolean?
function utils.api.decreasePlayerStatus(playerId, status, amount)
    local player = tracker:getPlayer(playerId)
    local playerStatus = player and player:getStatus(status)

    return player and player:setStatus(status, player:getStatus(status) - amount)
end

---@param resource string
local function onResourceStop(resource)
    if resource == cache.resource then
        GlobalState:set("statuses", nil, true)
    end
end

AddEventHandler("onResourceStop", onResourceStop)
AddEventHandler("onServerResourceStop", onResourceStop)

---Setup the status system for players that are already logged in (in case of resource restart)
do
    CreateThread(function()
        GlobalState:set("statuses", config.statuses, true)
    end)

    Wait(1000) -- wait for global statebag to initializes

    local xPlayers, count = ESX.GetExtendedPlayers()

    for i = 1, count, 1 do
        local xPlayer = xPlayers[i]

        onPlayerLoaded(xPlayer.playerId, xPlayer)
    end
end
