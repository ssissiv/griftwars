local Thicket = class( "Location.Thicket", Location )

Thicket.WORLDGEN_TAGS = { "boundary east", "boundary west", "boundary south", "boundary north",
	"forest east", "forest west", "forest south", "forest north", }

function Thicket:OnSpawn( world )
	Location.OnSpawn( self, world )

	self:SetDetails( "Thicket", "Trees everywhere!")
	self:SpawnPerimeterPortals( "forest" )
end


function Thicket:GenerateTileMap()
	if self.map == nil then
		self.map = self:GainAspect( Aspect.TileMap() )
		self.map:FillTiles( 12, 12, function( x, y )
			if self.world:Random() < 0.2 then
				return Tile.Tree( x, y )
			else
				return Tile.Grass( x, y )
			end
		end )
	end
end

