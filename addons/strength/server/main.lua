local strength = require("addons.strength.shared.config")

exports["esx_status"]:registerGlobalStatus("strength", strength.status)

ESX.RegisterServerCallback("esx_status:updateStrengthOnFighting", function(source, cb)
    cb(exports["esx_status"]:increasePlayerStatus(source, "strength", strength.config.updateAmountOnFighting))
end)
