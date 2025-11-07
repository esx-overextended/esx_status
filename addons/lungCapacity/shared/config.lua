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
        updateInterval = 15 * 1000,
        updateAmountOnSwimming = 0.15,
        showNotificationOnUpdate = true,
        minimumMultiplier = 20.00, -- minimum float multiplier time in seconds to hold breathing underwater when lung capacity status gets to 0 - in seconds (20.00 means 20 seconds)
        maximumMultiplier = 80.00  -- maximum float multiplier time in seconds to hold breathing underwater when lung capacity status gets to 100 - in seconds (80.00 means 80 seconds)
    }
}
