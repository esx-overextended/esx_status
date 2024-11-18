local stamina = require("addons.stamina.shared.config")

exports["esx_status"]:registerGlobalStatus("stamina", stamina.status)

ESX.RegisterServerCallback("esx_status:updateStaminaOnRunning", function(source, cb)
    cb(exports["esx_status"]:increasePlayerStatus(source, "stamina", stamina.config.updateAmountOnRunning))
end)
