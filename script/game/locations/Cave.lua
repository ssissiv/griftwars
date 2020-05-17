
-----------------------------------------------------------------------

local Cave = class( "Location.Cave", Location )

Cave.WORLDGEN_TAGS = { "cave exit" }

function Cave:init()
	Location.init( self )
	self:SetDetails( "Cave", "A dark cave." )

	self:GainAspect( Feature.Home() )

	Portal.CaveEntrance( "cave exit"):WarpToLocation( self )
end

function Cave:GenerateTileMap()
	if self.map == nil then
		self.map = self:GainAspect( Aspect.TileMap( 12, 12 ))
		self.map:FillTiles( function( x, y )
			return Tile.DirtFloor( x, y )
		end )
	end
end
