
-----------------------------------------------------------------------

local Cave = class( "Location.Cave", Location )

Cave.WORLDGEN_TAGS = { "cave exit" }

function Cave:init( ...)
	Location.init( self, ... )
	self:SetDetails( "Cave", "A dark cave." )

	self:GainAspect( Feature.Home() )

	Portal.CaveEntrance( "cave exit"):WarpToLocation( self )
end

function Cave:OnSpawn( world )
	Location.OnSpawn( self, world )
	
	local chest = Object.Chest()
	chest:WarpToLocation( self )
	chest:SpawnLoot( LOOT_JUNK_T3 )
end

function Cave:GenerateTileMap()
	if self.map == nil then
		self.map = self:GainAspect( Aspect.TileMap( 12, 12 ))
		self.map:FillTiles( function( x, y )
			return Tile.DirtFloor( x, y )
		end )
	end
end
