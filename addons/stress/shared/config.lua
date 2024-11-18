return {
    ---@type StatusConfig
    status = {
        value = 0,
        min = 0,
        max = 100,
        update = -0.16,
        decimal = 2,
    },
    config = {
        minimumValueToStartEffect = 50,
        blurLevels = {
            [1] = {
                min = 50,
                max = 60,
                intensity = 2000,
                timeout = math.random(50000, 60000)
            },
            [2] = {
                min = 60,
                max = 70,
                intensity = 2500,
                timeout = math.random(40000, 50000)
            },
            [3] = {
                min = 70,
                max = 80,
                intensity = 3000,
                timeout = math.random(30000, 40000)
            },
            [4] = {
                min = 80,
                max = 90,
                intensity = 3500,
                timeout = math.random(20000, 30000)
            },
            [5] = {
                min = 90,
                max = 100,
                intensity = 4000,
                timeout = math.random(10000, 20000)
            }
        }
    }
}
