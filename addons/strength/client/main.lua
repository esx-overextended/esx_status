local strength, isThreadActive
local playerId = PlayerId()
local config = require("addons.strength.shared.config").config
local minMaxDifference = config.maximumMultiplier - config.minimumMultiplier
local DEBUG = require("shared.config").debug

local function strengthThread()
    if isThreadActive then return end

    isThreadActive = true

    CreateThread(function()
        while isThreadActive do
            local playerPedId = PlayerPedId()

            if IsPedInMeleeCombat(playerPedId) then
                local isTargetting, targetEntity = GetPlayerTargetEntity(playerId)

                if isTargetting and not IsEntityDead(targetEntity) and GetMeleeTargetForPed(playerPedId) ~= 0 then
                    ESX.TriggerServerCallback("esx_status:updateStrengthOnFighting", function(isSuccessful)
                        if isSuccessful then
                            if config.showNotificationOnUpdate then
                                lib.notify({
                                    title = "Strength",
                                    description = ("Increased by +%s"):format(config.updateAmountOnFighting),
                                    position = "center-right",
                                    duration = 5000,
                                    showDuration = true,
                                    icon = "fa-solid fa-dumbbell",
                                    iconColor = "#ffe600",
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
                                ESX.Trace("Strength could NOT be update by its update amount on player fighting!", "error", true)
                            end
                        end
                    end)
                end
            end

            Wait(config.updateInterval)
        end
    end)
end

AddStateBagChangeHandler("strength", ("player:%s"):format(GetPlayerServerId(playerId)), function(_, _, value)
    ---@cast value number?

    strength = value

    ESX.Trace(("Strength: %s"):format(strength), "trace", true)

    if not strength then
        isThreadActive = false
        return
    end

    local multiplier = config.minimumMultiplier + ((strength * minMaxDifference) / 100)

    SetPlayerMeleeWeaponDamageModifier(playerId, multiplier)
    SetPlayerMeleeWeaponDefenseModifier(playerId, multiplier)
    StatSetInt("MP0_STRENGTH", strength, false) -- update stat on pause menu

    strengthThread()
end)
