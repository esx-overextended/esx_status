local hunger, isThreadActive
local config = require("addons.hunger.shared.config").config

local function zeroHunger()
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

AddStateBagChangeHandler("hunger", ("player:%s"):format(GetPlayerServerId(PlayerId())), function(_, _, value)
    ---@cast value number?

    hunger = value

    ESX.Trace(("Hunger: %s"):format(hunger), "trace", true)

    if not hunger or hunger > 0 then
        isThreadActive = false
        return
    end

    zeroHunger()
end)
