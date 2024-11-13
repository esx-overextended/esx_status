local Status = {}
Status.__index = Status

local utils = require("shared.utils")
local DEBUG = require("shared.config").debug

---@param amount number
function Status:setAmount(amount)
    if not type(amount) == "number" then
        if DEBUG then
            ESX.Trace("Status:setAmount(amount) error type!", "error", true)
        end

        return false
    end

    self.amount = amount

    return true
end

---@param name string
---@param amount number
return function(name, amount)
    return setmetatable({
        name = name,
        amount = amount
    }, Status)
end