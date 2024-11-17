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
    return toBoolean[value]
end

---@param number number
---@param decimal number
---@return number
function utils.roundNumberToDecimal(number, decimal)
    local multiplier = 10 ^ decimal
    return math.floor(number * multiplier + 0.5) / multiplier
end

---@param name string
---@param value number | string | boolean
---@return boolean, number | string | boolean | nil
function utils.isStatusValueValid(name, value)
    if not statuses[name] then return false, nil end

    local status = statuses[name]
    local receivedType = type(value)
    local expectedType = type(status.value)

    if expectedType == "number" and receivedType == "number" then
        if status.min and value < status.min then return false, nil end
        if status.max and value > status.max then return false, nil end

        if status.decimal then
            value = utils.roundNumberToDecimal(value, status.decimal)
        end

        return true, value
    elseif expectedType == "string" and receivedType == "string" then
        if status.acceptedValues then
            return acceptedStringValues[name][value], value
        end

        return true, value
    elseif expectedType == "boolean" then
        if receivedType == "boolean" then
            return true, value
        elseif receivedType == "string" or receivedType == "number" then
            local convertedValue = utils.toBoolean(value)

            return type(convertedValue) ~= "nil" and true, convertedValue
        end
    end

    return false, nil
end

utils.api = setmetatable({}, {
    __newindex = function(_, index, value)
        return exports(index, value)
    end
})

return utils
