local Bed = class( "Object.Bed", Object )
Bed.MAP_CHAR = "b"
Bed.image = assets.TILE_IMG.BED


function Bed:GetName()
	return "Bed"
end
