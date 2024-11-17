local hunger
local isThreadActive = false
local threadInterval = 30 * 1000
local decreaseHealthRange = { min = 5, max = 10 }

local function zeroHunger()
    if isThreadActive then return end

    isThreadActive = true

    CreateThread(function()
        while isThreadActive do
            if ESX.PlayerLoaded and not ESX.PlayerData.dead then
                local playerPedId = PlayerPedId()
                local currentHealth = GetEntityHealth(playerPedId)
                local decreaseThreshold = math.random(decreaseHealthRange.min, decreaseHealthRange.max)

                SetEntityHealth(playerPedId, currentHealth - decreaseThreshold)
            end

            Wait(threadInterval)
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
