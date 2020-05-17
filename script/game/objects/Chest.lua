local Chest = class( "Object.Chest", Object )
Chest.MAP_CHAR = "C"
Chest.image = assets.TILE_IMG.CHEST


function Chest:GetName()
	return "Chest"
end
