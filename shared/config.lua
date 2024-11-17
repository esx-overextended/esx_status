---@class StatusConfig
---@field value number | string | boolean -- (mandatory) default value
---@field min? number -- (optional) only works if value type is number
---@field max? number -- (optional) only works if value type is number
---@field update? number -- (optional) only works if value type is number
---@field decimal? number -- (optional) only works if value type is number
---@field acceptedValues? string[] -- (optional) only works if value type is string

return {
    debug = true,
    updateInterval = 30 * 1000,

    ---@type table<string, StatusConfig>
    statuses = {
        -- growth = {
        --     value = "low",
        --     acceptedValues = {
        --         "low",
        --         "medium",
        --         "high"
        --     }
        -- }
    }
}
