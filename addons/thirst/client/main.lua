local thirst, isThreadActive
local config = require("addons.thirst.shared.config").config

local function zeroThirst()
    if isThreadActive then return end

    isThreadActive = true

    CreateThread(function()
        while isThreadActive do
            if ESX.PlayerLoaded and not ESX.PlayerData.dead then
                local currentHealth = GetEntityHealth(ESX.PlayerData.ped)
                local decreaseThreshold = math.random(config.healthDecreaseRange.min, config.healthDecreaseRange.max)

                SetEntityHealth(ESX.PlayerData.ped, currentHealth - decreaseThreshold)
            end

            Wait(config.healthDegradeInterval)
        end
    end)
end

AddStateBagChangeHandler("thirst", ("player:%s"):format(GetPlayerServerId(PlayerId())), function(_, _, value)
    ---@cast value number?

    thirst = value

    ESX.Trace(("Thirst: %s"):format(thirst), "trace", true)

    if not thirst or thirst > 0 then
        isThreadActive = false
        return
    end

    zeroThirst()
end)
