
-- @export  OpenMakeupCustomization : Use exports.tpz_makeup:OpenMakeupCustomization(data) to execute.
-- @param data : requires the following:
-- @param data.Coords { table form }
-- @param data.Lighting vector3 form.
-- @param data.CameraCoords - required the following:
-- CameraCoords = { x = 0 y = 0, z = 0, h = 0, roty = 0.0, rotz = 0.0, zoom = 10.0},
exports('OpenMakeupCustomization', function(data)
    OpenMakeupCustomization(nil, true, data) -- <- DO NOT TOUCH
end)