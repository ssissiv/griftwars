
-----------------------------------------------------------------------

local BottomOfWell = class( "Location.BottomOfWell", Location )

BottomOfWell.WORLDGEN_TAGS = { "bottom_of_well exit" }

function BottomOfWell:init( ... )
	Location.init( self, ... )
	self:SetDetails( "Bottom of the Well", "The dried out bottom of an abandoned cave." )

	-- Portal.CaveEntrance( "cave exit"):WarpToLocation( self )
end

function BottomOfWell:OnSpawn( world )
	Location.OnSpawn( self, world )
	
	local chest = Object.Chest()
	chest:WarpToLocation( self )
	chest:GenerateLoot( LOOT_JUNK_T3 )
end

function BottomOfWell:GenerateTileMap()
	if self.map == nil then
		self.map = self:GainAspect( Aspect.TileMap( 6, 6 ))
		self.map:FillTiles( function( x, y )
			if x == 1 or x == 6 or y == 1 or y == 6 then
				return Tile.StoneWall( x, y )
			else
				return Tile.DirtFloor( x, y )
			end
		end )
	end
end
