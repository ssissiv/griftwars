
local TentInterior = class( "Aspect.TentInterior", Aspect.TileMap )

function TentInterior:GenerateTileMap()
	self:FillTiles( 5, 5, function( x, y )
		return Tile.DirtFloor( x, y )
	end )
end

-----------------------------------------------------------------------

local TentInterior = class( "Location.TentInterior", Location )

function TentInterior:init()
	Location.init( self )
	self:SetDetails( "Tent", "This is somebody's tent." )
	self:GainAspect( Aspect.TentInterior())

	self:GainAspect( Feature.Home() )

	Object.Bed():WarpToLocation( self )

	Object.Portal( "tent"):WarpToLocation( self )

end
