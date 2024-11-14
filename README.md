# esx_status (work in progress - not finished)

Cross-platform Exports
```lua
--Server

---@param statusName string
---@param statusData table<string, any>
---@return boolean?
---@param statusName string
---@return boolean?
exports["esx_status"]:registerGlobalStatus(statusName, statusData)

---@param statusName string
---@return boolean?
exports["esx_status"]:unregisterGlobalStatus(statusName)

---@param playerId number
---@param status string
---@return number?
exports["esx_status"]:getPlayerStatus(playerId, status)

---@param playerId number
---@return table<string, number>?
exports["esx_status"]:getAllPlayerStatus(playerId)

---@param playerId number
---@param status string
---@param amount number
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
```

<hr>

Besides exports, Player statuses can also be retrieved through statebags:
```lua
--Server
Player(1).state.hunger ---@return number?

--Client
LocalPlayer.state.hunger ---@return number?
```
