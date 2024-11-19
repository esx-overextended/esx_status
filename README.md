# esx_status

Cross-platform Exports
```lua
-----------------------------------------
-------------SERVER EXPORTS--------------
-----------------------------------------

---@param statusName string
---@param statusData StatusConfig
---@return boolean?
exports["esx_status"]:registerGlobalStatus(statusName, statusData)

---@param statusName string
---@return boolean?
exports["esx_status"]:unregisterGlobalStatus(statusName)

---@param playerId number
---@param status string
---@return number | string | boolean | nil
exports["esx_status"]:getPlayerStatus(playerId, status)

---@param playerId number
---@return table<string, number | string | boolean>?
exports["esx_status"]:getAllPlayerStatus(playerId)

---@param playerId number
---@param status string
---@param value number | string | boolean
---@return boolean?
exports["esx_status"]:setPlayerStatus(playerId, status, amount)

---@param playerId number
---@param status string
---@param amount number
---@return boolean?
exports["esx_status"]:increasePlayerStatus(playerId, status, amount)

---@param playerId number
---@param status string
---@param amount number
---@return boolean?
exports["esx_status"]:decreasePlayerStatus(playerId, status, amount)



-----------------------------------------
-------------CLIENT EXPORTS--------------
-----------------------------------------

---@param statusName string
---@return StatusConfig?
exports["esx_status"]:getGlobalStatus(statusName)

---@return table<string, StatusConfig>
exports["esx_status"]:getGlobalStatuses()
```

<hr>

Besides exports, Player statuses can also be retrieved through statebags:
```lua
--Server
Player(1).state.hunger ---@return number?

--Client
LocalPlayer.state.hunger ---@return number?
```
