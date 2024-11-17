return {
    ---@type StatusConfig
    status = {
        value = 100,
        min = 0,
        max = 100,
        update = -0.45,
        decimal = 2,
    },
    config = {
        healthDegradeInterval = 30 * 1000,
        healthDecreaseRange = { min = 5, max = 10 }
    }
}
