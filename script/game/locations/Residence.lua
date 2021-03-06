
local ResidenceTileMap = class( "Aspect.ResidenceTileMap", Aspect.TileMap )

function ResidenceTileMap:GenerateTileMap()
	self:FillTiles( 8, 8, function( x, y )
		if x == 1 or y == 1 or x == self.w or y == self.h then
			return Tile.StoneWall( x, y )
		else
			return Tile.WoodenFloor( x, y )
		end
	end )
end

-----------------------------------------------------------------------

local Residence = class( "Location.Residence", Location )

Residence.WORLDGEN_TAGS = { "residence exit" }


function Residence:init()
	Location.init( self )
	self:SetDetails( "Residence", "This is somebody's residence." )
	self:GainAspect( Aspect.ResidenceTileMap())

	self:GainAspect( Feature.Home() )

	Object.Bed():WarpToLocation( self )

	Object.Door( "residence exit"):Lock():WarpToLocation( self )

end

function Residence:SetResident( resident )
	if resident then
		self:GetAspect( Feature.Home ):AddResident( resident )
	end
end
