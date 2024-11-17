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
        -- hunger = {
        --     value = 50,
        --     update = -0.03
        -- },
        -- thirst = {
        --     value = 50,
        --     update = -0.04
        -- },
        -- stamina = {
        --     value = 50,
        --     update = -0.01
        -- },
        -- strength = {
        --     value = 50,
        --     update = -0.01
        -- },
        -- driving = {
        --     value = 50,
        --     update = -0.01
        -- },
        -- stress = {
        --     value = 50,
        --     update = -0.01
        -- },
        -- health = {
        --     value = 50
        -- },
        -- energy = {
        --     value = 50,
        --     update = -0.01
        -- },
        -- sleep = {
        --     value = 0,
        --     update = 0.01
        -- },
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
