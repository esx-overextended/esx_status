local thirst
local isThreadActive = false
local threadInterval = 30 * 1000
local decreaseHealthRange = { min = 5, max = 10 }

local function zeroThirst()
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
