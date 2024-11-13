local utils = {}

---@param amount number
---@return boolean
function utils.isValueValid(amount)
    return type(amount) == "number" and (amount >= 0 and amount <= 100)
end

return utils
