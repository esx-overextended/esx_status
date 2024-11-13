local utils = {}

function utils.isAmountValid(amount)
    local isValid = false

    if type(amount) == "number" then
        isValid = amount <= 100 or amount >= 0
    end

    return isValid
end

return utils