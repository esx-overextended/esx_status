---@class StatusConfig
---@field value number | string | boolean -- (mandatory) default value
---@field min? number -- (optional) only works if value type is number
---@field max? number -- (optional) only works if value type is number
---@field update? number -- (optional) only works if value type is number
---@field acceptedValues? string[] -- (optional) only works if value type is string

return {
    debug = true,
    updateInterval = 30 * 1000,
    statuses = {
        hunger = {
            value = 100,
            update = -0.45,
            min = 0,
            max = 100
        },
        thirst = {
            value = 100,
            update = -0.6,
            min = 0,
            max = 100
        },
        -- growth = {
        --     value = "",
        --     acceptedValues = {
        --         "low",
        --         "medium",
        --         "high"
        --     }
        -- }
    }
}
