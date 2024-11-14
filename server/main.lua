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

---@param resource string
local function onResourceStop(resource)
    if resource == cache.resource then
        GlobalState:set("statuses", nil, true)

        if DEBUG then
            ESX.Trace("Cleared GlobalState['statuses'] on resource stop", "trace", true)
        end
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

-----------------------------------------
-----------------EXPORTS-----------------
-----------------------------------------

---Generates an export to register a status in the system
---@param statusName string
---@param statusData table<string, any>
---@return boolean?
function utils.api.registerGlobalStatus(statusName, statusData)
    local registeredStatuses = GlobalState["statuses"]

    if registeredStatuses[statusName] then
        ESX.Trace(("exports:registerGlobalStatus(%s) error status already exist!"):format(statusName), "error", true)

        return false
    end

    if type(statusName) ~= "string" or type(statusData) ~= "table" or type(statusData?.value) ~= "number" then
        ESX.Trace(("exports:registerGlobalStatus(%s) error type!"):format(statusName), "error", true)

        return false
    end

    registeredStatuses[statusName] = statusData
    GlobalState:set("statuses", registeredStatuses)

    --Register the new status for already logged in players
    for _, playerData in pairs(tracker:getAllPlayers()) do
        playerData:registerStatus(statusName, statusData.value)
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
    local registeredStatuses = GlobalState["statuses"]

    if not registeredStatuses[statusName] then
        ESX.Trace(("exports:unregisterGlobalStatus(%s) error status does not exist!"):format(statusName), "error", true)

        return false
    end

    registeredStatuses[statusName] = nil
    GlobalState:set("statuses", registeredStatuses)

    --Unregister the status from already logged in players
    for _, playerData in pairs(tracker:getAllPlayers()) do
        playerData:unregisterStatus(statusName)
    end

    if DEBUG then
        ESX.Trace(("exports:unregisterGlobalStatus(%s) was successful!"):format(statusName), "trace", true)
    end

    return true
end

---Generates an export to retrieve the specified player's status value
---@param playerId number
---@param status string
---@return number?
function utils.api.getPlayerStatus(playerId, status)
    local player = tracker:getPlayer(playerId)

    return player and player:getStatus(status)
end

---Generates an export to retrieve all of the specified player's status values
---@param playerId number
---@return table<string, number>?
function utils.api.getAllPlayerStatus(playerId)
    local player = tracker:getPlayer(playerId)

    return player and player:getAllStatus()
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
    local currentAmount = player and player:getStatus(status)

    ---@diagnostic disable-next-line: need-check-nil
    return currentAmount and player:setStatus(status, currentAmount + amount)
end

---Generates an export to decrease the specified player's status value
---@param playerId number
---@param status string
---@param amount number
---@return boolean?
function utils.api.decreasePlayerStatus(playerId, status, amount)
    local player = tracker:getPlayer(playerId)
    local currentAmount = player and player:getStatus(status)

    ---@diagnostic disable-next-line: need-check-nil
    return currentAmount and player:setStatus(status, currentAmount - amount)
end

-----------------------------------------
-----------------EXPORTS-----------------
-----------------------------------------

local statusDecayAmount = 0.2    -- Amount to decrease from each status
local BATCH_SIZE = 32            -- Static batch size

CreateThread(function()
    while true do
        Citizen.Wait(config.updateInterval)
        
        local batchStart = 1
        local validStatuses = {}
        local allPlayers = GetPlayers()
        local numOfPlayers = #allPlayers
        
        for name, data in pairs(GlobalState["statuses"]) do
            validStatuses[name] = type(value.update) and value.update
        end

        while batchStart <= numOfPlayers do
            local batchEnd = math.min(batchStart + BATCH_SIZE - 1, numOfPlayers)
            local statusesChanged = false

            -- Process each player in the batch
            for i = batchStart, batchEnd do
                local playerId = allPlayers[i]
                local player = tracker:getPlayer(playerId)

                if not player then goto skipPlayer end
                
                local playerStatuses = player:getAllStatus()

                -- Iterate through each player's statuses and apply decay
                for statusName, statusValue in pairs(playerStatuses) do
                    if validStatuses[statusName] then
                        if player:setStatus(statusName, statusValue - validStatuses[statusName]) then
                            statusesChanged = true
                        end
                    end   
                end

                --TODO reduce function calls by getting all framework players at once
                if statusesChanged then
                    local xPlayer = ESX.GetPlayerFromId(playerId)

                    if xPlayer then
                        xPlayer.setMetadata("statuses", player:getAllStatus())
                    end
                end

                ::skipPlayer::
            end

            -- Move to the next batch and apply delay
            batchStart = batchEnd + 1
            Citizen.Wait(100)  -- Apply delay after each batch
        end
    end
end)
