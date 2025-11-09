local utils  = require("shared.utils")
local config = require("shared.config")

local hud    = {}

---@param statusName any
---@param inputStatusValue? any
---@return boolean
local function sanitizeInputForHud(statusName, inputStatusValue)
    local typeInput = type(inputStatusValue)
    if typeInput ~= "number" and typeInput ~= "nil" then
        if config.debug then
            ESX.Trace("The status '" .. statusName .. "' requires a numeric|nil value, but received a " .. typeInput .. ".", "trace", true)
        end
        return false
    end

    local typeConfig = type(config.statuses[statusName]?.value)
    if typeConfig ~= "number" then
        if config.debug then
            ESX.Trace("The status '" .. statusName .. "' does not support numeric values.", "trace", true)
        end
        return false
    end

    if not config.statuses[statusName]?.hud then
        if config.debug then
            ESX.Trace("The status '" .. statusName .. "' does not support HUD.", "trace", true)
        end

        return false
    end

    return true
end

local function handleHudForStatus(statusName)
    if not sanitizeInputForHud(statusName) then return false end

    ---@cast statusName string

    if hud[statusName] then return true end

    hud[statusName] = AddStateBagChangeHandler(statusName, ("player:%s"):format(GetPlayerServerId(PlayerId())), function(_, _, statusAmount)
        if not sanitizeInputForHud(statusName, statusAmount) then return end

        ---@cast statusAmount number | nil

        if statusAmount == nil or statusAmount <= config.statuses[statusName].min then
            return TriggerEvent("hud:client:BuffEffect", {
                display = false,
                buffName = statusName
            })
        end

        TriggerEvent("hud:client:BuffEffect", {
            display = true,
            buffName = statusName,
            progressValue = statusAmount,
            iconName = config.statuses[statusName].hud.iconName,
            iconColor = config.statuses[statusName].hud.iconColor,
            progressColor = config.statuses[statusName].hud.progressColor
        })
    end)

    return true
end

local function unhandleHudForStatus(statusName)
    if type(statusName) ~= "string" then return end

    if hud[statusName] then
        RemoveStateBagChangeHandler(hud[statusName])

        hud[statusName] = nil

        TriggerEvent("hud:client:BuffEffect", {
            display = false,
            buffName = statusName
        })
    end
end

local function ensureStatusHud()
    local newHud = {}

    for statusName in pairs(config.statuses) do
        if handleHudForStatus(statusName) then
            newHud[statusName] = true
        end
    end

    for statusName in pairs(hud) do
        if not newHud[statusName] then
            unhandleHudForStatus(statusName)
        end
    end

    -- cleanup
    table.wipe(newHud)
    newHud = nil
end


AddStateBagChangeHandler("statuses", "global", function(_, _, value)
    if not value then return end

    ---@cast value table<string, StatusConfig>

    config.statuses = value

    ensureStatusHud()
end)

do
    config.statuses = GlobalState["statuses"]

    ensureStatusHud()
end

-----------------------------------------
-----------------EXPORTS-----------------
-----------------------------------------

---Generates an export to get the specified registered status in the system
---@param statusName string
---@return StatusConfig?
function utils.api.getGlobalStatus(statusName)
    return config.statuses[statusName]
end

---Generates an export to get all registered statuses in the system
---@return table<string, StatusConfig>
function utils.api.getGlobalStatuses()
    return config.statuses
end

-----------------------------------------
-----------------EXPORTS-----------------
-----------------------------------------
