return {
    ---@type StatusConfig
    status = {
        value = 0,
        min = 0,
        max = 100,
        update = -0.3,
        decimal = 2,
    },
    config = {
        blurLevels = {
            {
                min = 10,
                max = 20,
                intensity = 1000,
                timeout = function() return math.random(100000, 120000) end
            },
            {
                min = 20,
                max = 30,
                intensity = 1250,
                timeout = function() return math.random(80000, 100000) end
            },
            {
                min = 30,
                max = 40,
                intensity = 1500,
                timeout = function() return math.random(60000, 80000) end
            },
            {
                min = 40,
                max = 50,
                intensity = 1750,
                timeout = function() return math.random(50000, 60000) end
            },
            {
                min = 50,
                max = 60,
                intensity = 2000,
                timeout = function() return math.random(50000, 60000) end
            },
            {
                min = 60,
                max = 70,
                intensity = 3000,
                timeout = function() return math.random(40000, 50000) end
            },
            {
                min = 70,
                max = 80,
                intensity = 4000,
                timeout = function() return math.random(30000, 40000) end
            },
            {
                min = 80,
                max = 90,
                intensity = 5000,
                timeout = function() return math.random(20000, 30000) end
            },
            {
                min = 90,
                max = 100,
                intensity = 6000,
                timeout = function() return math.random(10000, 20000) end
            }
        }
    }
}
