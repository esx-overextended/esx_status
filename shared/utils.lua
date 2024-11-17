local utils = {}
local statuses = require("shared.config").statuses
local toBoolean = { ["false"] = false, ["true"] = true, [0] = false, [1] = true }

AddStateBagChangeHandler("statuses", "global", function(_, _, value)
    statuses = value
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
        --TODO strict string value based on an declared enum in config?
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
