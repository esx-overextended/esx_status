local stress, isThreadActive
local config = require("addons.stress.shared.config").config

---@param stressValue number
---@return { intensity: number, timeout:number }
local function getBlurLevel(stressValue)
    local blurLevel = { intensity = 1500, timeout = 60000 }

    for i = 1, #config.blurLevels do
        local level = config.blurLevels[i]

        if stressValue >= level.min and stressValue <= level.max then
            blurLevel.timeout = level.timeout()
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
        local transitionTime = 1000.00
        local transitionMarginToIntensity = 100.00 -- we should increase this if players are remaining blurred in low levels for longer than expected

        while isThreadActive do
            if ESX.PlayerLoaded and not ESX.PlayerData.dead then
                local blurLevel = getBlurLevel(stress)

                if blurLevel.intensity <= (transitionTime + transitionMarginToIntensity) then
                    blurLevel.intensity = transitionTime + transitionMarginToIntensity
                end

                -- ESX.Trace(("Applying stress(%s) blur: intensity=%s, timeout=%s"):format(stress, blurLevel.intensity, blurLevel.timeout), "trace", true)

                TriggerScreenblurFadeIn(transitionTime)
                Wait(blurLevel.intensity)
                TriggerScreenblurFadeOut(transitionTime)

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
                        TriggerScreenblurFadeIn(transitionTime)
                        Wait(blurLevel.intensity)
                        TriggerScreenblurFadeOut(transitionTime)
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

    -- ESX.Trace(("Stress: %s"):format(stress), "trace", true)

    if stress then
        StatSetFloat("MP0_PLAYER_MENTAL_STATE", stress, false) -- update stat on pause menu
    end

    if not stress or stress < config.blurLevels[1]?.min then
        isThreadActive = false
        return
    end

    stressThread()
end)
