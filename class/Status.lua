---@class Status
---@field name string
---@field value number
local Status = {}
Status.__index = Status

setmetatable(Status, {
    __index = Status,
    __metatable = false
})

local utils = require("shared.utils")
local DEBUG = require("shared.config").debug

---@return string
function Status:getName()
    return self.name
end

---@return number
function Status:getValue()
    return self.value
end

---@param value number
---@return boolean
function Status:setValue(value)
    if type(value) ~= "number" then
        ESX.Trace(("Status:setValue(%s) for %s error type!"):format(value, self.name), "error", true)

        return false
    end

    if not utils.isValueValid(value) then
        if DEBUG then
            ESX.Trace(("Status:setValue(%s) for %s error value is not valid!"):format(value, self.name), "trace", true)
        end

        return false
    end

    self.value = value

    return true
end

---@param name string
---@param value number
---@return Status?
return function(name, value)
    local typeName = type(name)
    local typeValue = type(value)

    if typeName ~= "string" then
        return ESX.Trace(("Invalid nam passed while creating an instance of Status class! Received '%s', expected 'number'"):format(typeName), "error", true)
    end

    if typeValue ~= "number" then
        return ESX.Trace(("Invalid value passed while creating an instance of Status class! Received '%s', expected 'string'"):format(typeValue), "error", true)
    end

    return setmetatable({
        name = name,
        value = value
    }, Status)
end
