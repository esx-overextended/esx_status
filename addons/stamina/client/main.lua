local stamina, isThreadActive
local playerId = PlayerId()
local config = require("addons.stamina.shared.config").config
local minMaxDifference = config.maximumMultiplier - config.minimumMultiplier
local DEBUG = require("shared.config").debug

local function staminaThread()
    if isThreadActive then return end

    isThreadActive = true

    CreateThread(function()
        while isThreadActive do
            if IsPedRunning(PlayerPedId()) then
                ESX.TriggerServerCallback("esx_status:updateStaminaOnRunning", function(isSuccessful)
                    if isSuccessful then
                        if config.showNotificationOnUpdate then
                            lib.notify({
                                title = "Stamina",
                                description = ("Increased by +%s"):format(config.updateAmountOnRunning),
                                position = "center-right",
                                duration = 5000,
                                showDuration = true,
                                icon = "fa-solid fa-person-running",
                                iconColor = "#28ed09",
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
                            ESX.Trace("Stamina could NOT be update by its update amount on player running!", "error", true)
                        end
                    end
                end)
            end

            Wait(config.updateInterval)
        end
    end)
end

AddStateBagChangeHandler("stamina", ("player:%s"):format(GetPlayerServerId(playerId)), function(_, _, value)
    ---@cast value number?

    stamina = value

    ESX.Trace(("Stamina: %s"):format(stamina), "trace", true)

    if not stamina then
        isThreadActive = false
        return
    end

    local multiplier = config.minimumMultiplier + ((stamina * minMaxDifference) / 100)

    SetSwimMultiplierForPlayer(playerId, multiplier)
    SetRunSprintMultiplierForPlayer(playerId, multiplier)
    StatSetInt("MP0_STAMINA", stamina, false) -- update stat on pause menu

    staminaThread()
end)
