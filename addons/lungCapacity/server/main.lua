local lungCapacity = require("addons.lungCapacity.shared.config")

exports["esx_status"]:registerGlobalStatus("lungCapacity", lungCapacity.status)

ESX.RegisterServerCallback("esx_status:updateLungCapacityOnSwimming", function(source, cb)
    cb(exports["esx_status"]:increasePlayerStatus(source, "lungCapacity", lungCapacity.config.updateAmountOnSwimming))
end)
