local utils = {}
local statuses = require("shared.config").statuses
local toBoolean = {["false"] = false, ["true"] = true, [0] = false, [1] = true}

AddStateBagChangeHandler("statuses", "global", function(_, _, value)
    statuses = value
end)

---@param value number | string
---@return boolean?
function utils.toBoolean(value)
    local booleanValue = toBoolean[value]
    return type(booleanValue) = "boolean" and booleanValue or nil
end

---@param status string
---@param value number | string | boolean
---@return boolean
function utils.isStatusValueValid(name, value)
    if not statuses[name] then return false end

    local status = statuses[name]
    local receivedType = type(value)
    local expectedType = type(status)

    if expectedType == "number" and receivedType == "number" then
        if status.min and value < status.min then return false end
        if status.max and value > status.max then return false end

        return true
    elseif expectedType == "string" and receivedType == "string" then
        --TODO strict string value based on an declared enum in config?
        return true
    elseif expectedType == "boolean" and (receivedType == "boolean" or receivedType == "string" or receivedType == "number") then
        local convertedValue = receivedType ~= "boolean" and utils.toBoolean(value) or value
        
        return type(convertedValue) ~= "nil" and convertedValue
    end

    return false
end

utils.api = setmetatable({}, {
    __newindex = function(_, index, value)
        return exports(index, value)
    end
})

return utils
