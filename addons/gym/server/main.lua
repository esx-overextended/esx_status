local config = require("addons.gym.shared.config").config
local workouts = require("addons.gym.shared.config").workouts
local locations = require("addons.gym.shared.config").locations

--- validates a gym workout UID formatted as "gymName::workoutName::indexNumber"
---@param input string
---@return boolean valid, string? gymName, string? workoutName, number|string? indexOrErr
local function validateWorkoutUID(input)
    -- Type check
    if type(input) ~= "string" then
        return false, nil, nil, "Input must be a string"
    end

    -- Separator check (must have exactly two "::")
    local sepCount = select(2, input:gsub("::", ""))
    if sepCount ~= 2 then
        return false, nil, nil, "Invalid separator count"
    end

    -- Extract parts
    local gymName, workoutName, indexStr = input:match("^([^:]+)::([^:]+)::([^:]+)$")
    if not (gymName and workoutName and indexStr) then
        return false, nil, nil, "Invalid format"
    end

    -- Trim leading/trailing whitespace
    gymName = gymName:match("^%s*(.-)%s*$")
    workoutName = workoutName:match("^%s*(.-)%s*$")
    indexStr = indexStr:match("^%s*(.-)%s*$")

    -- Validate characters (letters, digits, underscore, dash, space)
    if gymName:match("[^%w_%-%s]") then
        return false, nil, nil, "Invalid characters in gym name"
    end
    if workoutName:match("[^%w_%-%s]") then
        return false, nil, nil, "Invalid characters in workout name"
    end

    -- Validate numeric index
    local idx = tonumber(indexStr)
    if not idx or idx < 1 or idx % 1 ~= 0 then
        return false, nil, nil, "Invalid index"
    end

    -- All checks passed
    return true, gymName, workoutName, idx
end

ESX.RegisterServerCallback("esx_status:gym:workout", function(source, cb, workoutUID)
    local valid, gymName, workoutName, indexOrErr = validateWorkoutUID(workoutUID)

    if not valid then
        -- DropPlayer(source, "Invalid workout data format detected")
        ESX.Trace(("[Cheat Detection] %s (ID: %s) sent an invalid workout uid: %s (%s)"):format(GetPlayerName(source), source, workoutUID, indexOrErr), "error", true)

        return cb(false)
    end

    if locations[gymName]?.zones?.workouts?[workoutName]?[indexOrErr]?.unique then
        if GlobalState[workoutUID] then
            return cb(false, locale("gym_workout_zone_busy"))
        end

        GlobalState:set(workoutUID, true, false)
    end

    Player(source).state:set("workoutUID", workoutUID, false)

    return cb(true)
end)


RegisterNetEvent("esx_status:gym:workoutSuccessful", function()
    local playerState = Player(source).state
    local workoutUID = playerState["workoutUID"]

    local valid, gymName, workoutName, indexOrErr = validateWorkoutUID(workoutUID)

    if not valid then
        -- DropPlayer(source, "Invalid workout data format detected")
        ESX.Trace(("[Cheat Detection] %s (ID: %s) has an invalid workout uid: %s (%s)"):format(GetPlayerName(source), source, workoutUID, indexOrErr), "error", true)

        return
    end

    if locations[gymName]?.zones?.workouts?[workoutName]?[indexOrErr]?.unique then
        GlobalState:set(workoutUID, false, false)
    end

    playerState:set("workoutUID", false, false)

    for status, details in pairs(workouts[workoutName]?.effects) do
        exports[cache.resource]:increasePlayerStatus(source, status, details.updateAmount)
    end
end)

RegisterNetEvent("esx_status:gym:workoutCancelled", function()
    local playerState = Player(source).state
    local workoutUID = playerState["workoutUID"]

    local valid, gymName, workoutName, indexOrErr = validateWorkoutUID(workoutUID)

    if not valid then
        -- DropPlayer(source, "Invalid workout data format detected")
        ESX.Trace(("[Cheat Detection] %s (ID: %s) has an invalid workout uid: %s (%s)"):format(GetPlayerName(source), source, workoutUID, indexOrErr), "error", true)

        return
    end

    if locations[gymName]?.zones?.workouts?[workoutName]?[indexOrErr]?.unique then
        GlobalState:set(workoutUID, false, false)
    end

    playerState:set("workoutUID", false, false)
end)

local function onResourceStop(resourceName)
    if resourceName ~= cache.resource then return end

    local players = GetPlayers()

    for i = 1, #players do
        local playerState = Player(players[i]).state
        local workoutUID = playerState["workoutUID"]

        if workoutUID then
            GlobalState:set(workoutUID, false, false)
            playerState:set("workoutUID", false, false)

            if config.debug then
                ESX.Trace(("Setting GlobalState[%s] to false through onResourceStop"):format(workoutUID), "trace", true)
            end
        end
    end
end

AddEventHandler("onResourceStop", onResourceStop)
AddEventHandler("onServerResourceStop", onResourceStop)

local function onPlayerLogout(playerId)
    local playerState = Player(playerId).state
    local workoutUID = playerState["workoutUID"]

    if workoutUID then
        GlobalState:set(workoutUID, false, false)
        playerState:set("workoutUID", false, false)

        if config.debug then
            ESX.Trace(("Setting GlobalState[%s] to false through onPlayerLogout"):format(workoutUID), "trace", true)
        end
    end
end

AddEventHandler("playerDropped", function(_)
    onPlayerLogout(source)
end)

AddEventHandler("esx:playerDropped", function(source)
    onPlayerLogout(source)
end)
