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

---@return number | string | boolean
function Status:getValue()
    return self.value
end

---@param value number | string | boolean
---@return boolean
function Status:setValue(value)
    local isValueValid, trimmedValue = utils.isStatusValueValid(self.name, value)

    if not isValueValid then
        if DEBUG then
            ESX.Trace(("Status:setValue(%s) for %s error value is not valid!"):format(value, self.name), "trace", true)
        end

        return false
    end

    ---@cast trimmedValue -nil

    self.value = trimmedValue

    return true
end

---@param name string
---@param value number | string | boolean
---@return Status?
return function(name, value)
    local typeName = type(name)
    local typeValue = type(value)

    if typeName ~= "string" then
        return ESX.Trace(("Invalid name passed while creating an instance of Status class! Expected ^2'string'^7, Received ^1'%s'^7"):format(typeName), "error", true)
    end

    if typeValue ~= "number" and typeValue ~= "string" and typeValue ~= "boolean" then
        return ESX.Trace(("Invalid value passed while creating an instance of Status class! Expected ^2'number' or 'string' or 'boolean'^7, Received ^1'%s'^7"):format(typeValue), "error", true)
    end

    local self = setmetatable({
        name = name,
        value = value
    }, Status)

    return self:setValue(value) and self or nil
end
