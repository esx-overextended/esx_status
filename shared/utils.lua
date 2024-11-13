local utils = {}

---@param amount number
---@return boolean
function utils.isValueValid(amount)
    return type(amount) == "number" and (amount >= 0 and amount <= 100)
end

utils.api = setmetatable({}, {
    __newindex = function(_, index, value)
        return exports(index, value)
    end
})

return utils
