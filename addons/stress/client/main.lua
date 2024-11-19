local stress, isThreadActive
local config = require("addons.stress.shared.config").config

---@param stressValue number
---@return { intensity: number, timeout:number }
local function getBlurLevel(stressValue)
    local blurLevel = { intensity = 1500, timeout = 60000 }

    for i = 1, #config.blurLevels do
        local level = config.blurLevels[i]

        if stressValue >= level.min and stressValue <= level.max then
            blurLevel.timeout = level.timeout
            blurLevel.intensity = level.intensity
            break
        end
    end

    return blurLevel
end

local function stressThread()
    if isThreadActive then return end

    isThreadActive = true

    CreateThread(function()
        while isThreadActive do
            if ESX.PlayerLoaded and not ESX.PlayerData.dead then
                local blurLevel = getBlurLevel(stress)

                TriggerScreenblurFadeIn(1000.0)
                Wait(blurLevel.intensity)
                TriggerScreenblurFadeOut(1000.0)

                if stress >= 100 then
                    local fallRepeat = math.random(2, 4)
                    local ragdollTimeout = fallRepeat * 1750

                    if not IsPedRagdoll(ESX.PlayerData.ped) and IsPedOnFoot(ESX.PlayerData.ped) and not IsPedSwimming(ESX.PlayerData.ped) then
                        SetPedToRagdollWithFall(ESX.PlayerData.ped, ragdollTimeout, ragdollTimeout, 1, GetEntityForwardVector(ESX.PlayerData.ped) --[[@as number]], 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
                    end

                    Wait(1000)

                    for _ = 1, fallRepeat do
                        Wait(750)
                        DoScreenFadeOut(200)
                        Wait(1000)
                        DoScreenFadeIn(200)
                        TriggerScreenblurFadeIn(1000.0)
                        Wait(blurLevel.intensity)
                        TriggerScreenblurFadeOut(1000.0)
                    end
                end

                Wait(blurLevel.timeout)
            else
                Wait(1000)
            end
        end
    end)
end

AddStateBagChangeHandler("stress", ("player:%s"):format(GetPlayerServerId(PlayerId())), function(_, _, value)
    ---@cast value number?

    stress = value

    ESX.Trace(("Stress: %s"):format(stress), "trace", true)

    if stress then
        StatSetFloat("MP0_PLAYER_MENTAL_STATE", stress, false) -- update stat on pause menu
    end

    if not stress or stress < config.minimumValueToStartEffect then
        isThreadActive = false
        return
    end

    stressThread()
end)
