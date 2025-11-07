local lungCapacity, isThreadActive
local playerId = PlayerId()
local config = require("addons.lungCapacity.shared.config").config
local minMaxDifference = config.maximumMultiplier - config.minimumMultiplier
local DEBUG = require("shared.config").debug

local function lungCapacityThread()
    if isThreadActive then return end

    isThreadActive = true

    CreateThread(function()
        while isThreadActive do
            if IsPedSwimmingUnderWater(ESX.PlayerData.ped) then
                ESX.TriggerServerCallback("esx_status:updateLungCapacityOnSwimming", function(isSuccessful)
                    if isSuccessful then
                        if config.showNotificationOnUpdate then
                            lib.notify({
                                title = "Lung Capacity",
                                description = ("Increased by +%s"):format(config.updateAmountOnSwimming),
                                position = "center-right",
                                duration = 5000,
                                showDuration = true,
                                icon = "fa-solid fa-lungs",
                                iconColor = "#009dff",
                                iconAnimation = "beat",
                                style = {
                                    backgroundColor = "#2c3e50",                    -- Dark blue-gray background for contrast
                                    color = "#ecf0f1",                              -- Light color for text (title and description)
                                    borderRadius = "10px",                          -- Slightly rounded corners
                                    boxShadow = "0 0 25px 10px rgba(0, 0, 0, 0.4)", -- Soft shadow on all 4 sides
                                    fontSize = "15px",                              -- General font size
                                    [".description"] = {
                                        color = "#f1c40f",                          -- Golden yellow for description text
                                        fontWeight = "bold",                        -- Bold description for emphasis
                                        fontSize = "13px",                          -- Slightly smaller description text
                                    },
                                },
                            })
                        end
                    else
                        if DEBUG then
                            ESX.Trace("Lung capacity could NOT be update by its update amount on player swimming!", "error", true)
                        end
                    end
                end)
            end

            Wait(config.updateInterval)
        end
    end)
end

AddStateBagChangeHandler("lungCapacity", ("player:%s"):format(GetPlayerServerId(playerId)), function(_, _, value)
    ---@cast value number?

    lungCapacity = value

    -- ESX.Trace(("Lung Capacity: %s"):format(lungCapacity), "trace", true)

    if not lungCapacity then
        isThreadActive = false
        return
    end

    local multiplier = config.minimumMultiplier + ((lungCapacity * minMaxDifference) / 100)

    SetPedMaxTimeUnderwater(ESX.PlayerData.ped, multiplier)
    StatSetInt("MP0_LUNG_CAPACITY", lungCapacity, false) -- update stat on pause menu

    lungCapacityThread()
end)
