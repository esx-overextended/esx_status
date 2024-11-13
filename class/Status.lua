---@class Status
---@field name string
---@field value number
local Status = {}
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
        if DEBUG then
            ESX.Trace("Status:setValue error type!", "error", true)
        end

        return false
    end

    if not utils.isValueValid(value) then
        if DEBUG then
            ESX.Trace("Status:setValue error isValueValid!", "error", true)
        end

        return false
    end

    self.value = value

    return true
end

---@param amount number
---@return boolean
function Status:increaseValue(amount)
    return self:setValue(self.amount + amount)
end

---@param amount number
---@return boolean
function Status:decreaseValue(amount)
    return self:setValue(self.amount - amount)
end

---@param name string
---@param value number
---@return Status?
return function(name, value)
    if type(name) ~= "string" or type(value) ~= "number" then
        return ESX.Trace("Invalid parameters passed while creating an instance of Status class!", "error", true)
    end

    return setmetatable({
        name = name,
        value = value
    }, Status)
end
