-----------------------------------------
----------------UNIT TESTS---------------
-----------------------------------------

--Run unit tests upon starting the resource
if not require("test.units") then
    ESX.Trace(("Resource ^1%s^7 halted due to failed tests!"):format(cache.resource), "error", true)

    return StopResource(cache.resource)
end
-----------------------------------------
----------------UNIT TESTS---------------
-----------------------------------------

local utils            = require("shared.utils")
local config           = require("shared.config")
local tracker          = require("class.PlayerStatusRegistry")()
local DEBUG            = config.debug
local intervalStatuses = {}

AddStateBagChangeHandler("statuses", "global", function(_, _, value)
    if not value then return end

    ---@cast value table<string, StatusConfig>

    config.statuses = value

    for name, data in pairs(config.statuses) do
        intervalStatuses[name] = type(data.update) == "number" and type(data.value) == "number" and data.update
    end

    ---@cast intervalStatuses table<string, number?>
end)

---@param playerId number
---@param xPlayer table
local function onPlayerLoaded(playerId, xPlayer)
    local isSuccessful = tracker:addPlayer(playerId, xPlayer.metadata.statuses or {})

    if isSuccessful then
        TriggerEvent("esx_status:playerAdded", playerId)
        Player(playerId).state:set("esx_status:loaded", true, true)
    end

    if DEBUG then
        ESX.Trace(("Loading of playerId %s into the system was %s"):format(playerId, isSuccessful and "^2successful^7" or "^1unsuccessful^7"), "trace", true)
    end
end

---@param playerId number
local function onPlayerDropped(playerId)
    local player = tracker:getPlayer(playerId)
    local xPlayer = player and ESX.GetPlayerFromId(playerId)

    ---@diagnostic disable-next-line: need-check-nil
    if xPlayer then xPlayer.setMetadata("statuses", player:getAllStatus()) end

    local isSuccessful = tracker:removePlayer(playerId)

    if isSuccessful then
        TriggerEvent("esx_status:playerRemoved", playerId)
        Player(playerId).state:set("esx_status:loaded", false, true)
    end

    if DEBUG then
        ESX.Trace(("Removing of playerId %s from the system was %s"):format(playerId, isSuccessful and "^2successful^7" or "^1unsuccessful^7"), "trace", true)
    end
end

AddEventHandler("esx:playerLoaded", onPlayerLoaded)
AddEventHandler("esx:playerDropped", onPlayerDropped)

---@param resource string
local function onResourceStop(resource)
    if resource == cache.resource then
        for playerId in pairs(tracker:getAllPlayers()) do
            onPlayerDropped(playerId)
        end

        GlobalState:set("statuses", nil, true)

        if DEBUG then
            ESX.Trace("Cleared GlobalState['statuses'] on resource stop", "trace", true)
        end
    end
end

AddEventHandler("onResourceStop", onResourceStop)
AddEventHandler("onServerResourceStop", onResourceStop)

---Setup the status system for players that are already logged in (in case of resource restart)

CreateThread(function()
    GlobalState:set("statuses", config.statuses, true)

    Wait(1000) -- wait for global statebag to initializes

    local xPlayers, count = ESX.GetExtendedPlayers()

    for i = 1, count, 1 do
        local xPlayer = xPlayers[i]

        onPlayerLoaded(xPlayer.playerId, xPlayer)
    end
end)

-----------------------------------------
-----------------EXPORTS-----------------
-----------------------------------------

---Generates an export to register a status in the system
---@param statusName string
---@param statusData StatusConfig
---@return boolean?
function utils.api.registerGlobalStatus(statusName, statusData)
    if config.statuses[statusName] then
        ESX.Trace(("exports:registerGlobalStatus(%s) error status already exist!"):format(statusName), "error", true)

        return false
    end

    if type(statusName) ~= "string" or type(statusData) ~= "table" or type(statusData?.value) == "nil" then
        ESX.Trace(("exports:registerGlobalStatus(%s) error type!"):format(statusName), "error", true)

        return false
    end

    config.statuses[statusName] = statusData
    GlobalState:set("statuses", config.statuses, true)

    --Register the new status for already logged in players
    for _, player in pairs(tracker:getAllPlayers()) do
        player:registerStatus(statusName, statusData.value)
    end

    if DEBUG then
        ESX.Trace(("exports:registerGlobalStatus(%s) was successful!"):format(statusName), "trace", true)
    end

    return true
end

---Generates an export to unregister a status from the system
---@param statusName string
---@return boolean?
function utils.api.unregisterGlobalStatus(statusName)
    if not config.statuses[statusName] then
        ESX.Trace(("exports:unregisterGlobalStatus(%s) error status does not exist!"):format(statusName), "error", true)

        return false
    end

    config.statuses[statusName] = nil
    GlobalState:set("statuses", config.statuses, true)

    --Unregister the status from already logged in players
    for _, player in pairs(tracker:getAllPlayers()) do
        player:unregisterStatus(statusName)
    end

    if DEBUG then
        ESX.Trace(("exports:unregisterGlobalStatus(%s) was successful!"):format(statusName), "trace", true)
    end

    return true
end

---Generates an export to retrieve the specified player's status value
---@param playerId number
---@param status string
---@return number | string | boolean | nil
function utils.api.getPlayerStatus(playerId, status)
    local player = tracker:getPlayer(playerId)

    return player and player:getStatus(status)
end

---Generates an export to retrieve all of the specified player's status values
---@param playerId number
---@return table<string, number | string | boolean>?
function utils.api.getAllPlayerStatus(playerId)
    local player = tracker:getPlayer(playerId)

    return player and player:getAllStatus()
end

---Generates an export to set the specified player's status value
---@param playerId number
---@param status string
---@param value number | string | boolean
---@return boolean?
function utils.api.setPlayerStatus(playerId, status, value)
    local player = tracker:getPlayer(playerId)

    return player and player:setStatus(status, value)
end

---Generates an export to increase the specified player's status value
---@param playerId number
---@param status string
---@param amount number
---@return boolean?
function utils.api.increasePlayerStatus(playerId, status, amount)
    local player = tracker:getPlayer(playerId)

    return player and player:increaseStatus(status, amount)
end

---Generates an export to decrease the specified player's status value
---@param playerId number
---@param status string
---@param amount number
---@return boolean?
function utils.api.decreasePlayerStatus(playerId, status, amount)
    local player = tracker:getPlayer(playerId)

    return player and player:decreaseStatus(status, amount)
end

-----------------------------------------
-----------------EXPORTS-----------------
-----------------------------------------

local BATCH_SIZE = 32

CreateThread(function()
    while true do
        Wait(config.updateInterval)

        local batchStart = 1
        local allPlayers, numOfPlayers = ESX.GetExtendedPlayers()

        while batchStart <= numOfPlayers do
            local batchEnd = math.min(batchStart + BATCH_SIZE - 1, numOfPlayers)
            local anyStatusChanged = false

            -- process each player in the batch
            for i = batchStart, batchEnd do
                local xPlayer = allPlayers[i]
                local player = tracker:getPlayer(xPlayer.playerId)

                if not player then goto skipPlayer end

                local playerStatuses = player:getAllStatus()

                for statusName in pairs(playerStatuses) do
                    local updateAmount = intervalStatuses[statusName]

                    if updateAmount then
                        if player:increaseStatus(statusName, updateAmount) then
                            anyStatusChanged = true
                        end
                    end
                end

                if anyStatusChanged then
                    xPlayer.setMetadata("statuses", playerStatuses)
                end

                ::skipPlayer::
            end

            -- move to the next batch and apply delay
            batchStart = batchEnd + 1

            Wait(100) -- Apply delay after each batch
        end
    end
end)
