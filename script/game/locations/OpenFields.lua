local OpenFields = class( "Location.OpenFields", Location )

OpenFields.WORLDGEN_TAGS = { "boundary east", "boundary west", "boundary south", "boundary north",
	"fields east", "fields west", "fields south", "fields north", }

function OpenFields:OnSpawn( world )
	Location.OnSpawn( self, world )

	self:SetDetails( "Vast Fields", "Vast, flat meadows covered with grass and wild flowers.")
	self:SpawnPerimeterPortals( "fields" )

	if world:Random() < 0.4 then
		for i = 1, world:Random( 3 ) do
			Object.BerryBush():WarpToLocation( self )
		end
	end
end


function OpenFields:GenerateTileMap()
	if self.map == nil then
		self.map = self:GainAspect( Aspect.TileMap( 12, 12 ))
		self.map:FillTiles( function( x, y )
			return Tile.Grass( x, y )
		end )
	end
end

