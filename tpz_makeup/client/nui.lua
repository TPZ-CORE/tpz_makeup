local TPZ = exports.tpz_core:getCoreAPI()

local CameraHandler   = {handler = nil, coords = nil, zoom = 0, z = 0 }
local SELECTED_CATEGORY_TYPE = nil

local SelectedPlayerSkin = {} -- The selected skin (hair, beard, beardstabble)
local Groom              = nil

local overlayLookup = {
    ['lipsticks']  = 7,
    ['eyeliners']  = 15,
    ['shadows']    = 5,
    ['foundation'] = 5,
}

-----------------------------------------------------------
--[[ Local Functions ]]--
-----------------------------------------------------------

local ToggleUI = function(display, data)

    local PlayerData = GetPlayerData()

    if not display then 

        while not IsScreenFadedOut() do
            Wait(50)
            DoScreenFadeOut(2000)
        end

        RenderScriptCams(false, true, 500, true, true)
        SetCamActive(CameraHandler.handler, false)
        DetachCam(CameraHandler.handler)
        DestroyCam(CameraHandler.handler, true)

        SetNuiFocus(display, display)

        SendNUIMessage({ type = "enable", enable = display })

        PlayerData.HasNUIActive = false

        TaskStandStill(PlayerPedId(), 1)
        ClearPedTasksImmediately(PlayerPedId(), true)

        Wait(2000)
        DoScreenFadeIn(2000)

    else
        SetNuiFocus(display, display)
    
        SendNUIMessage({ type = "enable", enable = display })

    end
end

local LoadSelectedCategoryMakeupData = function(category)
    SELECTED_CATEGORY_TYPE  = category

    local ClientData = exports.tpz_core:getCoreAPI().GetPlayerClientData()
    local PlayerSkin = ClientData.skinComp
    
    PlayerSkin = json.decode(PlayerSkin)

	local current_component = PlayerSkin[category] and PlayerSkin[category].id or 0
	local current_color     = PlayerSkin[category] and PlayerSkin[category].primary_color or 0
	local current_color2    = PlayerSkin[category] and PlayerSkin[category].secondary_color or 0
	local current_variant   = PlayerSkin[category] and PlayerSkin[category].variant or 1
	local current_opacity   = PlayerSkin[category] and PlayerSkin[category].opacity or 9
		
	SendNUIMessage({ action = 'reset_makeup_components_list' })

	local max_elements = 3

	SendNUIMessage({
		action = 'insertMakeupCategoryElements',

		result = { 
			label    = Locales['NUI_MAKEUP_' .. string.upper(SELECTED_CATEGORY_TYPE) .. '_TEXTURE'],
			category = SELECTED_CATEGORY_TYPE,
			type     = 'texture_id',
			current  = current_component,
			max      = #Config.overlays_info[category],
		},
	})
	
	SendNUIMessage({
		action = 'insertMakeupCategoryElements',

		result = { 
			label    = Locales['NUI_MAKEUP_' .. string.upper(SELECTED_CATEGORY_TYPE) .. '_PRIMARY_COLOR'],
			category = SELECTED_CATEGORY_TYPE,
			type     = 'color',
			current  = current_color,
			max      = 63,
		},
	})

	if category == 'lipsticks' then 
		
		SendNUIMessage({
			action = 'insertMakeupCategoryElements',
	
			result = { 
				label    = Locales['NUI_MAKEUP_' .. string.upper(SELECTED_CATEGORY_TYPE) .. '_SECONDARY_COLOR'],
				category = SELECTED_CATEGORY_TYPE,
				type     = 'color2',
				current  = current_color2,
				max      = 63,
			},
		})

		max_elements = max_elements +1

	end

	if category == "lipsticks" or category == "shadows" or category == "eyeliners" or category == "foundation" then

		SendNUIMessage({
			action = 'insertMakeupCategoryElements',
	
			result = { 
				label    = Locales['NUI_MAKEUP_' .. string.upper(SELECTED_CATEGORY_TYPE) .. '_VARIANT'],
				category = SELECTED_CATEGORY_TYPE,
				type     = 'variant',
				current  = current_variant,
				max      = overlayLookup[category],
			},
		})

		max_elements = max_elements +1
	end

	-- opacity
	SendNUIMessage({
		action = 'insertMakeupCategoryElements',

		result = { 
			label    = Locales['NUI_MAKEUP_' .. string.upper(SELECTED_CATEGORY_TYPE) .. '_OPACITY'],
			category = SELECTED_CATEGORY_TYPE,
			type     = 'opacity',
			current  = current_opacity,
			max      = 9,
		},
	})

	SendNUIMessage( { action = 'selectedMakeupCategory', 
	
	    result = {
			title              = Locales['NUI_MAKEUP_' .. string.upper(SELECTED_CATEGORY_TYPE)],
			description        = Locales['NUI_MAKEUP_' .. string.upper(SELECTED_CATEGORY_TYPE) .. '_DESC'],
			max                = max_elements,
	
			current_texture_id = current_component,
			max_texture_id     = #Config.overlays_info[category],
	
			primary_color      = current_color,
			secondary_color    = current_color2,

			current_variant    = current_variant,
			max_variants       = overlayLookup[category] or 0,

			current_opacity    = current_opacity,
		}
	})

end

local UpdateCharacterMakeupTextures = function(data)
	local actionType, texture_id, color, color2, variant, opacity = data.type, data.texture_id, data.color, data.color2, data.variant, data.opacity
    
    local ClientData = exports.tpz_core:getCoreAPI().GetPlayerClientData()
    local PlayerSkin = ClientData.skinComp
    
    PlayerSkin = json.decode(PlayerSkin)

	if Config.Debug then
		print('[UPDATE] : Character Makeup Modification Request:', "Category: " .. SELECTED_CATEGORY_TYPE, "Type: " .. actionType, "Texture ID: " .. texture_id, "Primary Color: " .. color, "Secondary Color: " .. color2, "Variant: " .. variant, "Opacity: " .. opacity)
	end

	if SelectedPlayerSkin[SELECTED_CATEGORY_TYPE] == nil then
		SelectedPlayerSkin[SELECTED_CATEGORY_TYPE] = {}
	end

    local newOpacity = math.type(opacity) == "integer" and (opacity > 0 and opacity / 10 or 0.0) or opacity 

	SelectedPlayerSkin[SELECTED_CATEGORY_TYPE] = { 
		id              = texture_id, 
		primary_color   = color, 
		secondary_color = color2, 
		tertiary_color  = 0,
		visibility      = 1, 
		variant         = variant,
		opacity         = newOpacity
	}

	local visibility = SelectedPlayerSkin[SELECTED_CATEGORY_TYPE].id ~= 0 and 1 or 0
	SelectedPlayerSkin[SELECTED_CATEGORY_TYPE].visibility = visibility

	local overlay_data = SelectedPlayerSkin[SELECTED_CATEGORY_TYPE]

	ApplyOverlay(SELECTED_CATEGORY_TYPE, visibility,
	overlay_data.id, 1, 0, 0,
	1.0, 0, 1, overlay_data.primary_color, overlay_data.secondary_color or 0,
	overlay_data.tertiary_color or 0, overlay_data.variant or 1,
	overlay_data.opacity, PlayerSkin.albedo)

    if SelectedPlayerSkin[SELECTED_CATEGORY_TYPE] and PlayerSkin[SELECTED_CATEGORY_TYPE] then 

        if tablesAreSame(SELECTED_CATEGORY_TYPE, SelectedPlayerSkin, PlayerSkin) then
            SelectedPlayerSkin[SELECTED_CATEGORY_TYPE] = nil
        end

    end

    ReLoadAllRequired(true, false, SELECTED_CATEGORY_TYPE )

end

-- Required for eyebrows.
function SetGroomTexture(data)   
    
    local actionType, texture_id, color = data.type, data.texture_id, data.color

    local ClientData = exports.tpz_core:getCoreAPI().GetPlayerClientData()
    local PlayerSkin = ClientData.skinComp
    
    PlayerSkin = json.decode(PlayerSkin)

    local opacity   = tonumber(data.opacity)
    local _category = SELECTED_CATEGORY_TYPE == 'overlay' and 'hair_overlay' or SELECTED_CATEGORY_TYPE
    category = SELECTED_CATEGORY_TYPE == 'overlay' and 'hair' or SELECTED_CATEGORY_TYPE

    if Config.Debug then
        print('[UPDATE] : Character Groom Modification Request:', "Category: " .. _category, "Type: " .. actionType, "Texture ID: " .. texture_id, "Color: " .. color, "Opacity: " .. opacity)
    end

    if SelectedPlayerSkin[_category] == nil then
        SelectedPlayerSkin[_category] = {}
    end

    local newOpacity = math.type(opacity) == "integer" and (opacity > 0 and opacity / 10 or 0.0) or opacity 
   
    SelectedPlayerSkin[_category] = { 
        id         = texture_id, 
        color      = color, 
        visibility = data.visibility or 1, 
        opacity    = newOpacity
    }

    local visibility = (SelectedPlayerSkin[_category].id ~= 0 and SelectedPlayerSkin[_category].opacity > 0.0) and 1 or 0
    SelectedPlayerSkin[_category].visibility = visibility

    ApplyOverlay(category, visibility, SelectedPlayerSkin[_category].id, 1, 0, 0, 1.0, 0, 1, SelectedPlayerSkin[_category].color, 0, 0, 1, SelectedPlayerSkin[_category].opacity, PlayerSkin.albedo)

    if actionType == 'texture_id' then 

        SendNUIMessage({
            action = 'updateGroomSpecificData',
            max_colors = 63,
            category   = SELECTED_CATEGORY_TYPE,
        })

    end

    if SelectedPlayerSkin[_category] and PlayerSkin[_category] then

        -- We remove selected player skin in case its the same as the default one when opened the store.
        if tonumber(SelectedPlayerSkin[_category].id) == tonumber(PlayerSkin[_category].id) and tonumber(SelectedPlayerSkin[_category].color) == tonumber(PlayerSkin[_category].color) then
           
            if tonumber(SelectedPlayerSkin[_category].visibility) == tonumber(PlayerSkin[_category].visibility) and tonumber(SelectedPlayerSkin[_category].opacity) == tonumber(PlayerSkin[_category].opacity) then
                SelectedPlayerSkin[_category] = nil
            end
    
        end

    end

    ReLoadAllRequired(true, true) -- reloads lifestyle too

end

local LoadSelectedCategoryLifestyleData = function(category, title)

    local ClientData = exports.tpz_core:getCoreAPI().GetPlayerClientData()
    local PlayerSkin = ClientData.skinComp
    
    PlayerSkin = json.decode(PlayerSkin)

    SELECTED_CATEGORY_TYPE = category

	local componentData = PlayerSkin[category] or { id = 0, opacity = 1.0 }

    SendNUIMessage( { action = 'selectedLifestyleCategory', 

        result = {
            max             = #Config.overlays_info[string.lower(category)],
			current         = componentData.id,
			current_opacity = componentData.opacity,

			title           = title,
			description     = Locales['NUI_LIFESTYLES_' .. string.upper(SELECTED_CATEGORY_TYPE) .. '_INFO'] or ''
        }
    })

end

-- @data texture_id, opacity.
local function UpdateCharacterLifestyleTextures(data)
	local texture_id, opacity = tonumber(data.texture_id), data.opacity

    local ClientData = exports.tpz_core:getCoreAPI().GetPlayerClientData()
    local PlayerSkin = ClientData.skinComp
    
    PlayerSkin = json.decode(PlayerSkin)

	if Config.Debug then
		print('[UPDATE] : Character Lifestyle Modification Request:', "Category: " .. SELECTED_CATEGORY_TYPE, "Texture ID: " .. texture_id, "Opacity: " .. opacity)
	end

    local newOpacity = math.type(opacity) == "integer" and (opacity > 0 and opacity / 10 or 0.0) or opacity 

	if SelectedPlayerSkin[SELECTED_CATEGORY_TYPE] == nil then
		SelectedPlayerSkin[SELECTED_CATEGORY_TYPE] = { id = texture_id, opacity = newOpacity, visibility = 0 }
	end

	local color     = SELECTED_CATEGORY_TYPE == "grime" and 1 or 0
	local colortype = SELECTED_CATEGORY_TYPE == "grime" and 0 or 1

	SelectedPlayerSkin[SELECTED_CATEGORY_TYPE].id      = texture_id
	SelectedPlayerSkin[SELECTED_CATEGORY_TYPE].opacity = newOpacity

	local visibility = (SelectedPlayerSkin[SELECTED_CATEGORY_TYPE].id ~= 0 and SelectedPlayerSkin[SELECTED_CATEGORY_TYPE].opacity > 0.0) and 1 or 0
	SelectedPlayerSkin[SELECTED_CATEGORY_TYPE].visibility = visibility
	
	ApplyOverlay(string.lower(SELECTED_CATEGORY_TYPE), visibility, SelectedPlayerSkin[SELECTED_CATEGORY_TYPE].id, 0, 0, colortype, 1.0, 0, color, 0, 0, 0, 1, SelectedPlayerSkin[SELECTED_CATEGORY_TYPE].opacity, PlayerSkin.albedo)

    if SelectedPlayerSkin[SELECTED_CATEGORY_TYPE] and PlayerSkin[SELECTED_CATEGORY_TYPE] then
   
        -- We remove selected player skin in case its the same as the default one when opened the store.
     
        if tonumber(SelectedPlayerSkin[SELECTED_CATEGORY_TYPE].id) == tonumber(PlayerSkin[SELECTED_CATEGORY_TYPE].id) and tonumber(SelectedPlayerSkin[SELECTED_CATEGORY_TYPE].opacity) == tonumber(PlayerSkin[SELECTED_CATEGORY_TYPE].opacity) then
            SelectedPlayerSkin[SELECTED_CATEGORY_TYPE] = nil
        end

    end

    ReLoadAllRequired()
end

-----------------------------------------------------------
--[[ Functions ]]--
-----------------------------------------------------------

function GetCameraHandler()
    return CameraHandler
end

function OpenMakeupCustomization(locationIndex, isCustom, data)
    local PlayerData   = GetPlayerData()

    local LocationData

    if not isCustom then
        LocationData = Config.Stores[locationIndex]
    else 
        LocationData = data
    end
    
    while not IsScreenFadedOut() do
        Wait(50)
        DoScreenFadeOut(2000)
    end

    Wait(2000)

    TPZ.TeleportToCoords(LocationData.Coords.x, LocationData.Coords.y, LocationData.Coords.z, LocationData.Coords.h)

    local cameraCoords = LocationData.CameraCoords
    local handler = StartCam(cameraCoords.x, cameraCoords.y, cameraCoords.z, cameraCoords.rotx, cameraCoords.roty, cameraCoords.rotz, cameraCoords.zoom)
  
    CameraHandler.coords = { x = cameraCoords.x, y = cameraCoords.y, z = cameraCoords.z, rotx = cameraCoords.rotx, roty = cameraCoords.roty, rotz = cameraCoords.rotz, fov = cameraCoords.fov }
    CameraHandler.z    = cameraCoords.z
    CameraHandler.zoom = cameraCoords.zoom 
    CameraHandler.handler = handler

    PlayerData.HasNUIActive = true

    Citizen.CreateThread(function()
        
        while true do 
            Wait(0)

            if not PlayerData.HasNUIActive then 
                
                TaskStandStill(PlayerPedId(), 1)
                break
            end

            DisplayRadar(false)
            DrawLightWithRange(LocationData.Lighting, 255, 255, 255, 2.5, 50.0)
            TaskStandStill(PlayerPedId(), -1)
        end
    
    end)

    SendNUIMessage({ action = 'reset_categories' })

    local elements = {
        { label = Locales['NUI_MAKEUP_FOUNDATION'],        category = 'foundation', nui_call = 'request_selected_makeup_data' },
        { label = Locales['NUI_MAKEUP_LIPSTICKS'],         category = 'lipsticks',  nui_call = 'request_selected_makeup_data' },
        { label = Locales['NUI_MAKEUP_SHADOWS'],           category = 'shadows',    nui_call = 'request_selected_makeup_data' },
        { label = Locales['NUI_MAKEUP_EYELINERS'],         category = 'eyeliners',  nui_call = 'request_selected_makeup_data' },
        { label = Locales['NUI_MAKEUP_BLUSH'],             category = 'blush',      nui_call = 'request_selected_makeup_data' },
        { label = Locales['NUI_HAIR_EYEBROWS'],            category = 'eyebrows',   nui_call = 'request_selected_groom_data' },
        { label = Locales['NUI_LIFESTYLES_DISCOLORATION'], category = 'disc',       nui_call = 'request_selected_lifestyle_data' },
    }

    for _, element in pairs (elements) do 

        SendNUIMessage({
            action = 'insertCategory',
            result = element,
        })
        
    end

    Wait(2000)
    DoScreenFadeIn(2000)
    ToggleUI(true)

    SendNUIMessage({ action = 'set_information', title = Locales['TITLE'], locales = Locales, ismale = (IsPedMale(PlayerPedId()) and 1 or 0) } )

    if Groom == nil then 
        local gender  = IsPedMale(PlayerPedId()) == 1 and "Male" or "Female"
        Groom = LoadGroomData(gender)
    end

    SelectedPlayerSkin = {} -- reset
end

function CloseNUI()
    if GetPlayerData().HasNUIActive then SendNUIMessage({action = 'close'}) end
end

-----------------------------------------------------------
--[[ General NUI Callbacks ]]--
-----------------------------------------------------------

RegisterNUICallback('close', function()
	ToggleUI(false)
end)

-----------------------------------------------------------
--[[ Makeup Store NUI Callbacks ]]--
-----------------------------------------------------------

-- @data.category, @data.title
RegisterNUICallback('request_selected_lifestyle_data', function(data)
    LoadSelectedCategoryLifestyleData(data.category, data.title)
end)

RegisterNUICallback('set_lifestyle_textures', function(data)
    UpdateCharacterLifestyleTextures(data)
end)


-- @data.category, @data.title
-- Required for eyebrows.
RegisterNUICallback('request_selected_groom_data', function(data)
    local category, title = data.category, data.title

    SELECTED_CATEGORY_TYPE = category

	SendNUIMessage({ action = 'reset_components_list' })

    local ClientData = exports.tpz_core:getCoreAPI().GetPlayerClientData()
    local PlayerSkin = ClientData.skinComp

    PlayerSkin = json.decode(PlayerSkin)

    category                = category == 'overlay' and 'hair' or category
    local _category         = category == 'hair' and 'hair_overlay' or category
    local current_component = PlayerSkin[_category] and PlayerSkin[_category].id or 1
    local current_color     = PlayerSkin[_category] and PlayerSkin[_category].color or 1
    local current_opacity   = PlayerSkin[_category] and PlayerSkin[_category].opacity or 10

    local max_texture_id    = #Config.overlays_info[category]
    local max_colors        = 63

    -- texture_id
    SendNUIMessage({
        action = 'insertGroomCategoryElements',

        result = { 
            label    = Locales['NUI_GROOM_' .. string.upper(SELECTED_CATEGORY_TYPE) .. '_DESC'],
            category = SELECTED_CATEGORY_TYPE,
            type     = 'texture_id',
            current  = current_component,
            max      = max_texture_id,
        },
    })

    -- primary color.
    SendNUIMessage({
        action = 'insertGroomCategoryElements',

        result = { 
            label    = Locales['NUI_GROOM_' .. string.upper(SELECTED_CATEGORY_TYPE) .. '_COLORS'], 
            category = SELECTED_CATEGORY_TYPE,
            type     = 'color',
            current  = current_color,
            max      = max_colors
        },

    })


    -- opacity
    SendNUIMessage({
        action = 'insertGroomCategoryElements',

        result = { 
            label    = Locales['NUI_GROOM_' .. string.upper(SELECTED_CATEGORY_TYPE) .. '_OPACITY'],
            category = SELECTED_CATEGORY_TYPE,
            type     = 'opacity',
            current  = current_opacity,
            max      = 10,
        },
    })

    SendNUIMessage( { action = 'selectedGroomCategory', 
    
        result = {
            title              = title,
            description        = Locales['NUI_GROOM_' .. string.upper(SELECTED_CATEGORY_TYPE) .. '_INFO'],
            max                = 3,

            current_texture_id = current_component,
            max_texture_id     = max_texture_id,

            current_color      = current_color,
            max_colors         = 63,

            current_opacity    = current_opacity,
        }
    })

end)

RegisterNUICallback('set_groom_textures', function(data)
    SetGroomTexture(data)
end)

RegisterNUICallback('request_selected_makeup_data', function(data)
    LoadSelectedCategoryMakeupData(data.category)
end)

RegisterNUICallback('set_makeup_textures', function(data)
    UpdateCharacterMakeupTextures(data)
end)

-- makeup back for paying and saving.
RegisterNUICallback('back', function()

    local cost = SelectedPlayerSkin[SELECTED_CATEGORY_TYPE] == nil and 0 or Config.Prices[string.upper(SELECTED_CATEGORY_TYPE)]

    if cost == 0 then 
        return
    end

    local inputData = {
        title = Locales[string.upper(SELECTED_CATEGORY_TYPE)],
        desc = string.format(Locales['COST_DESCRIPTION'], cost),
        buttonparam1 = Locales['CONFIRM_BUTTON'],
        buttonparam2 = Locales['CANCEL_BUTTON'],
    }
                                
    TriggerEvent("tpz_inputs:getButtonInput", inputData, function(cb)
    
        local await = true
        local reset = true

        if cb == "ACCEPT" then

            -- data required for the callback and only.
            local data    = SelectedPlayerSkin[SELECTED_CATEGORY_TYPE]
            data.amount   = cost
            data.category = SELECTED_CATEGORY_TYPE

            local cb = exports.tpz_core:ClientRpcCall().Callback.TriggerAwait("tpz_makeup:canPurchase", data )

            if cb then 
                reset = false 
            end

            await = false
        else 
            await = false 
        end

        while await do 
            Wait(10)
        end

        if reset then

            local ClientData = exports.tpz_core:getCoreAPI().GetPlayerClientData()
            local PlayerSkin = ClientData.skinComp
            
            PlayerSkin = json.decode(PlayerSkin)
   
            if PlayerSkin[SELECTED_CATEGORY_TYPE] == nil then

                PlayerSkin[SELECTED_CATEGORY_TYPE] = {
                    id              = 0, 
                    primary_color   = 0, 
                    secondary_color = 0, 
                    tertiary_color  = 0,
                    visibility      = 1, 
                    variant         = 0,
                    opacity         = 0.0
                }

            end

            local makeupData = PlayerSkin[SELECTED_CATEGORY_TYPE]

            local data = { 
                type       = SELECTED_CATEGORY_TYPE, 
                texture_id = makeupData.id, 
                color      = makeupData.primary_color, 
                color2     = makeupData.secondary_color, 
                variant    = makeupData.variant, 
                opacity    = makeupData.opacity,
                visibility = makeupData.visibility,
            }

            UpdateCharacterMakeupTextures(data)

        end

    end) 

end)

-- groom back for paying and saving.
RegisterNUICallback('groom_back', function()
    
    local cost = SelectedPlayerSkin[SELECTED_CATEGORY_TYPE] == nil and 0 or Config.Prices[string.upper(SELECTED_CATEGORY_TYPE)]

    if cost == 0 then 
        return
    end

    local inputData = {
        title = Locales[string.upper(SELECTED_CATEGORY_TYPE)],
        desc = string.format(Locales['COST_DESCRIPTION'], cost),
        buttonparam1 = Locales['CONFIRM_BUTTON'],
        buttonparam2 = Locales['CANCEL_BUTTON'],
    }
                                
    TriggerEvent("tpz_inputs:getButtonInput", inputData, function(cb)
    
        local await = true
        local reset = true

        if cb == "ACCEPT" then

            -- data required for the callback and only.
            local data    = SelectedPlayerSkin[SELECTED_CATEGORY_TYPE]
            data.amount   = cost
            data.category = SELECTED_CATEGORY_TYPE

            local cb = exports.tpz_core:ClientRpcCall().Callback.TriggerAwait("tpz_makeup:canPurchase", data )

            if cb then 
                reset = false 
            end

            await = false
        else 
            await = false 
        end

        while await do 
            Wait(10)
        end

        if reset then
            
            local ClientData = exports.tpz_core:getCoreAPI().GetPlayerClientData()
            local PlayerSkin = ClientData.skinComp
            
            PlayerSkin = json.decode(PlayerSkin)

            SetGroomTexture({ 
                actionType = SELECTED_CATEGORY_TYPE,
                texture_id = PlayerSkin[SELECTED_CATEGORY_TYPE].id,
                color      = PlayerSkin[SELECTED_CATEGORY_TYPE].color,
                opacity    = PlayerSkin[SELECTED_CATEGORY_TYPE].opacity or 1.0,
                visibility = PlayerSkin[SELECTED_CATEGORY_TYPE].visibility or 0,
            })   

        end

    end) 

end)


-- lifestyle back for paying and saving.
RegisterNUICallback('lifestyle_back', function()
    
    local cost = SelectedPlayerSkin[SELECTED_CATEGORY_TYPE] == nil and 0 or Config.Prices[string.upper(SELECTED_CATEGORY_TYPE)]

    if cost == 0 then 
        return
    end

    local inputData = {
        title = Locales[string.upper(SELECTED_CATEGORY_TYPE)],
        desc = string.format(Locales['COST_DESCRIPTION'], cost),
        buttonparam1 = Locales['CONFIRM_BUTTON'],
        buttonparam2 = Locales['CANCEL_BUTTON'],
    }
                                
    TriggerEvent("tpz_inputs:getButtonInput", inputData, function(cb)
    
        local await = true
        local reset = true

        if cb == "ACCEPT" then

            -- data required for the callback and only.
            local data    = SelectedPlayerSkin[SELECTED_CATEGORY_TYPE]
            data.amount   = cost
            data.category = SELECTED_CATEGORY_TYPE

            local cb = exports.tpz_core:ClientRpcCall().Callback.TriggerAwait("tpz_makeup:canPurchase", data )

            if cb then 
                reset = false 
                SelectedPlayerSkin[SELECTED_CATEGORY_TYPE] = nil
            end

            await = false
        else 
            await = false 
        end

        while await do 
            Wait(10)
        end

        if reset then

            local ClientData = exports.tpz_core:getCoreAPI().GetPlayerClientData()
            local PlayerSkin = ClientData.skinComp
            
            PlayerSkin = json.decode(PlayerSkin)
            
            UpdateCharacterLifestyleTextures({
             texture_id = PlayerSkin[SELECTED_CATEGORY_TYPE].id,
             opacity    = PlayerSkin[SELECTED_CATEGORY_TYPE].opacity
            })
 
          
        end

    end) 

end)