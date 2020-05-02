local Thicket = class( "Location.Thicket", Location )

Thicket.WORLDGEN_TAGS = { "boundary east", "boundary west", "boundary south", "boundary north",
	"forest east", "forest west", "forest south", "forest north", }

function Thicket:init( zone, portal )
	Location.init( self )
	self:SetDetails( loc.format( "Thicket", zone.name), "Trees everywhere!")
	self.gen_portal = portal
end

function Thicket:OnSpawn( world )
	Location.OnSpawn( self, world )

	self:SpawnPerimeterPortals( "forest" )
end


function Thicket:GenerateTileMap()
	if self.map == nil then
		self.map = self:GainAspect( Aspect.TileMap( 12, 12 ))
		self.map:FillTiles( function( x, y )
			if math.random() < 0.2 then
				return Tile.Tree( x, y )
			else
				return Tile.Grass( x, y )
			end
		end )
	end
end

