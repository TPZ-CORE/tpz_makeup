
local StoreLocationPrompts = GetRandomIntInRange(0, 0xffffff)
local StoreLocationPromptsList = {}

--[[-------------------------------------------------------
 Handlers
]]---------------------------------------------------------

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    Citizen.InvokeNative(0x00EDE88D4D13CF59, StoreLocationPrompts) -- UiPromptDelete

    local PlayerData = GetPlayerData()

    if PlayerData.IsBusy then
        
        local CameraHandler = GetCameraHandler()

        RenderScriptCams(false, true, 500, true, true)
        SetCamActive(CameraHandler.handler, false)
        DetachCam(CameraHandler.handler)
        DestroyCam(CameraHandler.handler, true)

        TaskStandStill(PlayerPedId(), 1)
    end

    for i, v in pairs(Config.Stores) do
        if v.BlipHandle then
            RemoveBlip(v.BlipHandle)
        end
    end

end)

--[[-------------------------------------------------------
 Prompts
]]---------------------------------------------------------

RegisterStoreLocationPrompts = function()

    local str = Config.Prompts["OPEN_STORE"].label
    local keyPress = Config.Keys[Config.Prompts["OPEN_STORE"].key]
    
    local _prompt = PromptRegisterBegin()
    PromptSetControlAction(_prompt, keyPress)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(_prompt, str)
    PromptSetEnabled(_prompt, 1)
    PromptSetVisible(_prompt, 1)
    PromptSetStandardMode(_prompt, 1)
    PromptSetHoldMode(_prompt, 500)
    PromptSetGroup(_prompt, StoreLocationPrompts)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, _prompt, true)
    PromptRegisterEnd(_prompt)
    
    StoreLocationPromptsList = _prompt

end

function GetPromptData()
    return StoreLocationPrompts, StoreLocationPromptsList
end


--[[-------------------------------------------------------
 Blips Management
]]---------------------------------------------------------

function AddBlip(Store, StatusType)

    if Config.Stores[Store].BlipData then

        local BlipData = Config.Stores[Store].BlipData

        local sprite, blipModifier = BlipData.Sprite, 'BLIP_MODIFIER_MP_COLOR_32'

        if BlipData.OpenBlipModifier then
            blipModifier = BlipData.OpenBlipModifier
        end

        if StatusType == 'CLOSED' then
            sprite = BlipData.DisplayClosedHours.Sprite
            blipModifier = BlipData.DisplayClosedHours.BlipModifier
        end
        
        Config.Stores[Store].BlipHandle = N_0x554d9d53f696d002(1664425300, Config.Stores[Store].Coords.x, Config.Stores[Store].Coords.y, Config.Stores[Store].Coords.z)

        SetBlipSprite(Config.Stores[Store].BlipHandle, sprite, 1)
        SetBlipScale(Config.Stores[Store].BlipHandle, 0.2)

        Citizen.InvokeNative(0x662D364ABF16DE2F, Config.Stores[Store].BlipHandle, GetHashKey(blipModifier))

        Config.Stores[Store].BlipHandleModifier = blipModifier

        Citizen.InvokeNative(0x9CB1A1623062F402, Config.Stores[Store].BlipHandle, BlipData.Title)

    end
end

--[[-------------------------------------------------------
 NPC Management
]]---------------------------------------------------------

LoadModel = function(model)
    local model = GetHashKey(model)
    RequestModel(model)

    while not HasModelLoaded(model) do RequestModel(model)
        Citizen.Wait(100)
    end
end
 
RemoveEntityProperly = function(entity, objectHash)
    DeleteEntity(entity)
    DeletePed(entity)

    SetEntityAsNoLongerNeeded( entity )

    if objectHash then
        SetModelAsNoLongerNeeded(objectHash)
    end
   
end

--[[-------------------------------------------------------
 General
]]---------------------------------------------------------

StartCam = function(x, y, z, rotx, roty, rotz, fov)

    local cameraHandler = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", x, y, z, rotx, roty, rotz, fov, true, 0)
	SetCamActive(cameraHandler, true)
	RenderScriptCams(true, true, 500, true, true)

end

AdjustEntityPedHeading = function(amount)
	CurrentHeading = CurrentHeading + amount
	SetPedDesiredHeading(PlayerPedId(), CurrentHeading)
end


LoadGroomData = function(gender)

    local Groom = {}

    local hairComponents = exports.tpz_core:getCoreAPI().modules().file.load("component.data.playerHairComponents")

    while hairComponents == nil do 
        Wait(100)
    end

    for category, value in pairs(hairComponents[gender]) do

        local categoryTable = {}

        for _, v in ipairs(value) do

            local typeTable = {}

            for _, va in ipairs(v) do
                table.insert(typeTable, { hex = va.hash })
            end

            table.insert(categoryTable, typeTable)
        end

        Groom[category] = categoryTable
    end
   
    return Groom

end


function ApplyOverlay(name, visibility, tx_id, tx_normal, tx_material, tx_color_type, tx_opacity, tx_unk, palette_id, palette_color_primary, palette_color_secondary, palette_color_tertiary, var, opacity, albedo, ped)

    ped = ped or PlayerPedId()

    for k, v in pairs(Config.overlay_all_layers) do
        if v.name == name then
            v.visibility = visibility
            if visibility ~= 0 then
                v.tx_normal = tx_normal
                v.tx_material = tx_material
                v.tx_color_type = tx_color_type
                v.tx_opacity = tx_opacity
                v.tx_unk = tx_unk
                if tx_color_type == 0 then
                    v.palette = Config.color_palettes[name][palette_id]
                    v.palette_color_primary = palette_color_primary
                    v.palette_color_secondary = palette_color_secondary
                    v.palette_color_tertiary = palette_color_tertiary
                end
                if name == "shadows" or name == "eyeliners" or name == "lipsticks" then
                    v.var = var
                    if tx_id ~= 0 then
                        v.tx_id = Config.overlays_info[name][1].id
                    end
                else
                    v.var = 0
                    if tx_id ~= 0 then
                        v.tx_id = Config.overlays_info[name][tx_id].id
                    end
                end
                v.opacity = opacity
            end
        end
    end

    local gender = IsPedMale(PlayerPedId()) == 1 and 'Male' or 'Female'
    local current_texture_settings = Config.texture_types[gender]

    if textureId ~= -1 then
        Citizen.InvokeNative(0xB63B9178D0F58D82, textureId)
        Citizen.InvokeNative(0x6BEFAA907B076859, textureId)
    end

    textureId = Citizen.InvokeNative(0xC5E7204F322E49EB, albedo, current_texture_settings.normal, current_texture_settings.material)

    for k, v in pairs(Config.overlay_all_layers) do
        if v.visibility ~= 0 then
            local overlay_id = Citizen.InvokeNative(0x86BB5FF45F193A02, textureId, v.tx_id, v.tx_normal, v.tx_material, v.tx_color_type, v.tx_opacity, v.tx_unk)
            if v.tx_color_type == 0 then
                Citizen.InvokeNative(0x1ED8588524AC9BE1, textureId, overlay_id, v.palette)
                Citizen.InvokeNative(0x2DF59FFE6FFD6044, textureId, overlay_id, v.palette_color_primary, v.palette_color_secondary, v.palette_color_tertiary)
            end

            Citizen.InvokeNative(0x3329AAE2882FC8E4, textureId, overlay_id, v.var);
            Citizen.InvokeNative(0x6C76BC24F8BB709A, textureId, overlay_id, v.opacity);
        end
    end

    while not Citizen.InvokeNative(0x31DC8D3F216D8509, textureId) do
        Citizen.Wait(0)
    end

    Citizen.InvokeNative(0x92DAABA2C1C10B0E, textureId)
    Citizen.InvokeNative(0x0B46E25761519058, ped, joaat("heads"), textureId)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)
end

local keys = {
    "id",
    "primary_color",
    "secondary_color",
    "tertiary_color",
    "visibility",
    "variant",
    "opacity"
}

function tablesAreSame(category, a, b)
    for _, k in pairs(keys) do

        if a[category][k] ~= b[category][k] then
            return false
        end

    end
    return true
end

ReLoadAllRequired = function(reloadLifestyle, disableEyebrowsReload, disabledElement)

    local ClientData = exports.tpz_core:getCoreAPI().GetPlayerClientData()
    local skinComp = ClientData.skinComp

    skinComp = json.decode(skinComp)

    local ped = PlayerPedId()

    if reloadLifestyle then 

        local lifestyle_elements = {
            "moles",
            "spots",
            "complex",
            "acne",
            "freckles",
            "disc",
            "scars",
            "grime",
        }
    
        for _, element in pairs (lifestyle_elements) do 
    

            if element ~= disabledElement then

                if skinComp[element] then
    
                    local data = skinComp[element]
        
                    local color     = element == "grime" and 1 or 0
                    local colortype = element == "grime" and 0 or 1
        
                    ApplyOverlay(string.lower(element), data.visibility, 
                    data.id, 0, 0, 
                    colortype, 1.0, 0, color, 0, 0, 0, 1, 
                    data.opacity, skinComp.albedo, ped)
        
                end

            end
    
        end

    end

    -- Load Makeup
    local makeup_elements = {
        'foundation',
        'lipsticks',
        'shadows',
        'eyeliners',
        'blush',
    }

    for _, element in pairs (makeup_elements) do 

        if element ~= disabledElement then

            if skinComp[element] then
                local data = skinComp[element]
    
                ApplyOverlay(element, data.visibility,
                data.id, 1, 0, 0,
                1.0, 0, 1, data.primary_color, data.secondary_color or 0,
                data.tertiary_color or 0, data.variant or 1,
                data.opacity, skinComp.albedo, ped)
            else
                ApplyOverlay(element, 0,
                0, 1, 0, 0,
                1.0, 0, 1,  0, 0,
                0, 0,
                0.0, 0, ped)
    
            end
            
        end

    end

    if not disableEyebrowsReload then
        local groom_elements = {
            'eyebrows',
        }
    
        for _, element in pairs (groom_elements) do 
    
            if element ~= disabledElement then
                if skinComp[element] ~= nil then
    
                    local data = skinComp[element]
        
                    if element == 'hair' or element == 'bow' or element == 'beard' then
        
                        modules.IsPedReadyToRender(ped)
        
                        if data.id > 0 then 
        
                            local hash = groom[element][data.id][data.color].hex
                
                            modules.ApplyShopItemToPed(hash, ped)
                        end
                
                        modules.UpdatePedVariation(ped)
        
                    else
        
                        if element == 'overlay' or element == 'hair_overlay' then 
                            element = 'hair'
                        end
        
                        ApplyOverlay(element, data.visibility,
                        data.id, 1, 0, 0, 1.0, 0, 1, 
                        data.color, 0, 0, 1,
                        data.opacity, skinComp.albedo, ped)
                    end
        
                else
        
                    if element == 'hair' then
        
                        modules.IsPedReadyToRender(ped)
        
                        local hash = groom['hair'][1][1].hex
                
                        modules.ApplyShopItemToPed(hash, ped)
                
                        modules.UpdatePedVariation(ped)
        
                    elseif element == 'hair_overlay' then
        
                        if element == 'overlay' or element == 'hair_overlay' then 
                            element = 'hair'
                        end
        
                        ApplyOverlay(element, 0, 1, 1, 0, 0, 1.0, 0, 1, 0, 0, 0, 1, 0.0, skinComp['albedo'], ped)
                    end
        
                    if element == 'beardstabble' then 
                        ApplyOverlay('beardstabble', 0, 1, 1, 0, 0, 1.0, 0, 1, 0, 0, 0, 1, 0.0, skinComp['albedo'], ped)
                    end
        
                end

            end
    
    
        end

    end

end