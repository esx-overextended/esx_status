local isWorkingOut = false
local gymZones, gymWorkoutZones = {}, {}
local config = require("addons.gym.shared.config").config
local workouts = require("addons.gym.shared.config").workouts
local locations = require("addons.gym.shared.config").locations
local ox_target = GetResourceState("ox_target"):find("start") and exports["ox_target"]

local function skillCheck(data)
    data.inputs = type(data.extra.skillCheck.keys) == "table" and data.extra.skillCheck.keys or { "w", "a", "s", "d" }
    data.skillCheck = type(data.extra.skillCheck.mode) == "string" and { data.extra.skillCheck.mode } or type(data.extra.skillCheck.mode) == "table" and data.extra.skillCheck.mode or { "easy" }

    return lib.skillCheck(data.skillCheck, data.inputs)
end

local function executeSkillCheck(data)
    if not isWorkingOut then return end

    SetTimeout(data.extra.skillCheck.interval or 2000, function()
        if not isWorkingOut then return end

        if skillCheck(data) then
            executeSkillCheck(data)
        else
            lib.cancelProgress()
        end
    end)
end

local function onGymWorkoutSelected(data)
    if isWorkingOut or lib.progressActive() then
        return lib.notify({ title = locale("gym_title"), description = locale("gym_progress_busy"), type = "inform" })
    end

    isWorkingOut = true

    local result, message = ESX.TriggerServerCallback("esx_status:gym:workout", data.uid)

    if not result then
        isWorkingOut = false

        return message and lib.notify({ title = locale("gym_title"), description = message, type = "error" })
    end

    if data.unique then
        ---@diagnostic disable-next-line: missing-parameter
        SetEntityCoords(ESX.PlayerData.ped, data.unique.x, data.unique.y, data.unique.z)
        SetEntityHeading(ESX.PlayerData.ped, data.unique.w)
        FreezeEntityPosition(ESX.PlayerData.ped, true)
    end

    if config.skillCheck and data.extra.skillCheck then
        executeSkillCheck(data)
    end

    if lib.progressCircle({
            duration = data.extra.duration,
            position = "bottom",
            useWhileDead = false,
            allowRagdoll = false,
            allowCuffed = false,
            allowFalling = false,
            canCancel = true,
            disable = {
                move = true,
                car = true,
                combat = true
            },
            anim = {
                dict = data.extra.dictionary,
                clip = data.extra.clipset,
                flag = data.extra.flag,
                scenario = type(data.extra.scenario) == "table" and data.extra.scenario[math.random(#data.extra.scenario)] or data.extra.scenario
            },
            prop = data.extra.prop,
        }) then
        TriggerServerEvent("esx_status:gym:workoutSuccessful")

        for status, details in pairs(data.extra.effects) do
            if details.notify then
                lib.notify({ title = locale("gym_title"), description = locale(details.updateAmount < 0 and "gym_effect_decrease" or "gym_effect_increase", locale("gym_effect_" .. status), details.updateAmount), type = "success", duration = 5000 })
            end
        end
    else
        TriggerServerEvent("esx_status:gym:workoutCancelled")
        lib.notify({ title = locale("gym_title"), description = locale("gym_workout_cancelled"), type = "error" })
    end

    isWorkingOut = false

    if data.unique then
        FreezeEntityPosition(ESX.PlayerData.ped, false)
    end

    if gymWorkoutZones[data.id] and gymWorkoutZones[data.id].inZone then
        lib.showTextUI(locale("gym_exercise", data.extra.label or locale("gym_use")), { icon = data.extra.icon, iconColor = data.extra.iconColor })
    end
end

if not config.useTarget then
    function onGymWorkoutZoneEnter(data)
        if not gymWorkoutZones[data.id] or gymWorkoutZones[data.id].inZone then return end

        gymWorkoutZones[data.id].inZone = true

        if config.debug then ESX.Trace("entered workout zone " .. data.id, "trace", true) end

        lib.showTextUI(locale("gym_exercise", data.extra.label or locale("gym_use")), { icon = data.extra.icon, iconColor = data.extra.iconColor })

        CreateThread(function()
            while gymWorkoutZones[data.id] and gymWorkoutZones[data.id].inZone do
                if IsControlJustReleased(0, 38) then
                    lib.hideTextUI()
                    onGymWorkoutSelected(data)
                end

                Wait(0)
            end
        end)
    end

    function onGymWorkoutZoneExit(data)
        if not gymWorkoutZones[data.id] or not gymWorkoutZones[data.id].inZone then return end

        gymWorkoutZones[data.id].inZone = false

        if config.debug then ESX.Trace("exited workout zone " .. data.id, "trace", true) end

        --[[ -- apparently this was fixed in new ox_lib update. waiting for feedbacks whether to remove this block or use it again...
        for id in pairs(gymWorkoutZones) do
            if gymWorkoutZones[id].inZone then return end -- avoid hiding text ui if the player is in another workout zone (a workaround for ox_lib bug where sometimes it calls zone.onEnter earlier than zone.onExit)
        end
        ]]

        lib.hideTextUI()
    end
end

function onGymZoneEnter(data)
    if gymZones[data.id].inZone then return end

    gymZones[data.id].inZone = true

    if config.debug then ESX.Trace("entered gym zone " .. data.id, "trace", true) end

    for workoutName, workoutZones in pairs(data.gymWorkoutZones) do
        if workouts[workoutName] then
            for index, workoutZone in pairs(workoutZones) do
                if not config.useTarget then
                    local box = lib.zones.box({
                        coords = workoutZone.coords,
                        size = workoutZone.size,
                        rotation = workoutZone.rotation,
                        unique = workoutZone.unique,
                        debug = config.debug,
                        onEnter = onGymWorkoutZoneEnter,
                        onExit = onGymWorkoutZoneExit,
                        extra = workouts[workoutName],
                        uid = ("%s::%s::%s"):format(data.gymName, workoutName, index)
                    })

                    gymWorkoutZones[box.id] = { zone = box, inZone = false }
                else
                    local zoneSize = workoutZone.size + vector3(0.0, 0.0, 1.5) -- fix for 3rd eye not colliding with ground

                    if ox_target then
                        local id = ox_target:addBoxZone({
                            coords = workoutZone.coords,
                            size = zoneSize,
                            rotation = workoutZone.rotation,
                            debug = config.debug,
                            options = {
                                {
                                    name = data.gymName .. workoutName .. index,
                                    icon = workouts[workoutName].icon or "fas fa-sign-in-alt",
                                    label = workouts[workoutName].label or locale("gym_use"),
                                    distance = 1.5,
                                    unique = workoutZone.unique,
                                    extra = workouts[workoutName],
                                    onSelect = onGymWorkoutSelected,
                                    uid = ("%s::%s::%s"):format(data.gymName, workoutName, index)
                                }
                            }
                        })

                        table.insert(gymWorkoutZones, id)
                    end
                end
            end
        end
    end
end

function onGymZoneExit(data)
    if not gymZones[data.id].inZone then return end

    if config.debug then ESX.Trace("exited gym zone " .. data.id, "trace", true) end

    for id in pairs(gymWorkoutZones) do
        if not config.useTarget then
            onGymWorkoutZoneExit({ id = id })
            gymWorkoutZones[id].zone:remove()
        else
            if ox_target then
                ox_target:removeZone(gymWorkoutZones[id])
            end
        end
    end

    gymWorkoutZones = {}
    gymZones[data.id].inZone = false
end

---comment
---@param gymName string
---@param gymData table
local function registerGym(gymName, gymData)
    if gymData.blip then
        local blip = AddBlipForCoord(gymData.coords.x, gymData.coords.y, gymData.coords.z)

        SetBlipSprite(blip, gymData.blip.sprite)
        SetBlipScale(blip, gymData.blip.size)
        SetBlipColour(blip, gymData.blip.color)
        SetBlipAsShortRange(blip, true)

        AddTextEntry(gymName, gymData.label)
        BeginTextCommandSetBlipName(gymName)
        EndTextCommandSetBlipName(blip)
    end

    local sphere = lib.zones.sphere({
        coords = vector3(gymData.coords.x, gymData.coords.y, gymData.coords.z),
        radius = gymData.distance,
        debug = config.debug,
        onEnter = onGymZoneEnter,
        onExit = onGymZoneExit,
        gymWorkoutZones = gymData.zones.workouts,
        gymName = gymName
    })

    gymZones[sphere.id] = { zone = sphere, inZone = false }
end

exports("addGym", function(gymName, gymData)
    if locations[gymName] then
        return ESX.Trace(("Gym with name '%s' is already registered. Ignoring its registration..."):format(gymName), "warning", true)
    end

    locations[gymName] = gymData

    registerGym(gymName, gymData)
end)

for gymName, gymData in pairs(locations) do
    registerGym(gymName, gymData)
end
