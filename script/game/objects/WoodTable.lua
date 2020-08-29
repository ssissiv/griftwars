local WoodTable = class( "Object.WoodTable", Object )
WoodTable.image = assets.TILE_IMG.WOOD_TABLE
WoodTable.PASS_TYPE = IMPASS.ALL

function WoodTable:GetName()
	return "Wood Table"
end
