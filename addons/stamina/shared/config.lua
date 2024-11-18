return {
    ---@type StatusConfig
    status = {
        value = 0,
        min = 0,
        max = 100,
        update = -0.02,
        decimal = 2,
    },
    config = {
        updateInterval = 30 * 1000,
        updateAmountOnRunning = 0.15,
        showNotificationOnUpdate = true,
        minimumMultiplier = 1.00, -- minimum float multiplier speed amount to reach when stamina status gets to 0 - you can increase this value if you want players to run/swim faster than GTA default's in general - min is 1.0, max is 1.49, (based on fivem documentation)
        maximumMultiplier = 1.30  -- maximum float multiplier speed amount to reach when stamina status gets to 100 - you can lower this value if you think players are running/swimming too fast when their status increases - max is 1.49, min is 1.0 (based on fivem documentation)
    }
}
