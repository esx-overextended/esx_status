return {
    ---@type StatusConfig
    status = {
        value = 0,
        min = 0,
        max = 100,
        update = -0.01,
        decimal = 2,
    },
    config = {
        updateInterval = 10 * 1000,
        updateAmountOnFighting = 0.2,
        showNotificationOnUpdate = true,
        minimumMultiplier = 0.10, -- minimum float multiplier speed amount to reach when strength status gets to 0 - min is 0.10, max is 1.00
        maximumMultiplier = 1.00  -- maximum float multiplier speed amount to reach when strength status gets to 100 - max is 1.00, min is 0.10
    }
}
