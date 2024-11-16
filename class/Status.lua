---@class Status
---@field name string
---@field value number | string | boolean
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
    local typeValue = type(value)

    if typeValue ~= "number" and typeValue ~= "string" and typeValue ~= "boolean" then
        ESX.Trace(("Status:setValue(%s) for %s error type! Expected 'number' or 'string' or 'boolean', received '%s'"):format(value, self.name, typeValue), "error", true)

        return false
    end

    if not utils.isStatusValueValid(self.name, value) then
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
        return ESX.Trace(("Invalid nam passed while creating an instance of Status class! Received '%s', expected 'string'"):format(typeName), "error", true)
    end

    if typeValue ~= "number" then
        return ESX.Trace(("Invalid value passed while creating an instance of Status class! Received '%s', expected 'number'"):format(typeValue), "error", true)
    end

    return setmetatable({
        name = name,
        value = value
    }, Status)
end
