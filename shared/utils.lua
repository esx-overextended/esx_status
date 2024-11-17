local utils = {}
local statuses = require("shared.config").statuses --[[@as table<string, StatusConfig>]]
local toBoolean = { ["false"] = false, ["true"] = true, [0] = false, [1] = true }
local acceptedStringValues = {}

---@param receivedStatuses? table<string, StatusConfig>
function utils.refreshAcceptedStringValues(receivedStatuses)
    table.wipe(acceptedStringValues)

    for statusName, statusConfig in pairs(receivedStatuses or statuses) do
        if statusConfig.acceptedValues then
            acceptedStringValues[statusName] = {}

            for i = 1, #statusConfig.acceptedValues do
                acceptedStringValues[statusName][statusConfig.acceptedValues[i]] = true
            end
        end
    end
end

do utils.refreshAcceptedStringValues() end

AddStateBagChangeHandler("statuses", "global", function(_, _, value)
    if not value then return end

    ---@cast value table<string, StatusConfig>

    statuses = value

    utils.refreshAcceptedStringValues()
end)

---@param value number | string
---@return boolean?
function utils.toBoolean(value)
    local booleanValue = toBoolean[value]
    return type(booleanValue) == "boolean" and booleanValue or nil
end

---@param name string
---@param value number | string | boolean
---@return boolean
function utils.isStatusValueValid(name, value)
    if not statuses[name] then return false end

    local status = statuses[name]
    local receivedType = type(value)
    local expectedType = type(status.value)

    if expectedType == "number" and receivedType == "number" then
        if status.min and value < status.min then return false end
        if status.max and value > status.max then return false end

        return true
    elseif expectedType == "string" and receivedType == "string" then
        if status.acceptedValues then
            return acceptedStringValues[name][value]
        end

        return true
    elseif expectedType == "boolean" then
        if receivedType == "boolean" then
            return true
        elseif receivedType == "string" or receivedType == "number" then
            return type(utils.toBoolean(value)) ~= "nil" and true
        end
    end

    return false
end

utils.api = setmetatable({}, {
    __newindex = function(_, index, value)
        return exports(index, value)
    end
})

return utils
