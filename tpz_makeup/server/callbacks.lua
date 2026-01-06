
local TPZ = exports.tpz_core:getCoreAPI()

-----------------------------------------------------------
--[[ Callbacks  ]]--
-----------------------------------------------------------

exports.tpz_core:getCoreAPI().addNewCallBack("tpz_makeup:canPurchase", function(source, cb, data)
    local _source = source
    local xPlayer = TPZ.GetPlayer(_source)
  
    local money   = xPlayer.getAccount(0)
  
    local amount = Config.Prices[string.upper(data.category)]
    if money < amount then 
        SendNotification(_source, Locales['NOT_ENOUGH_MONEY'], "error")
        return cb (false)
    end

    xPlayer.removeAccount(0, amount)

    local skinComp = xPlayer.getOutfitComponents()
  
    -- if it's still a string (double encoded), decode again
    if type(skinComp) == "string" then
      skinComp = json.decode(skinComp)
    end
    
    if data.category == 'eyebrows' then 

        skinComp[data.category] = {
            id         = data.id, 
            color      = data.color, 
            visibility = data.visibility, 
            opacity    = data.opacity,
        }

    elseif data.category == 'disc' then 

        skinComp[data.category] = {
            id         = data.id, 
            visibility = data.visibility, 
            opacity    = data.opacity,
        }

    else   

        skinComp[data.category] = {
            id               = data.id, 
            primary_color    = data.primary_color, 
            secondary_color  = data.secondary_color, 
            tertiary_color   = data.tertiary_color,
            visibility       = data.visibility,
            variant          = data.variant,
            opacity          = data.opacity,
        }

    end

    local Parameters = {
        ["charidentifier"] = xPlayer.getCharacterIdentifier(),
        ['skinComp']       = json.encode(skinComp),
    } 
  
    exports.ghmattimysql:execute("UPDATE `characters` SET `skinComp` = @skinComp WHERE `charidentifier` = @charidentifier", Parameters)

    xPlayer.setOutfitComponents(json.encode(skinComp))

    SendNotification(_source, string.format(Locales['SUCCESSFULLY_PAID'], amount), 'success')

    return cb(true)
end)