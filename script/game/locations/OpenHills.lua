local OpenHills = class( "Location.OpenHills", Location )

OpenHills.WORLDGEN_TAGS = { "boundary east", "boundary west", "boundary south", "boundary north",
	"hills east", "hills west", "hills south", "hills north", }

function OpenHills:OnSpawn( world )
	Location.OnSpawn( self, world )

	self:SetDetails( "Open Hills", "Rolling hills. Travel is inconsistent.")
	self:SpawnPerimeterPortals( "hills" )

	if world:Random() < 0.1 then
		Portal.CaveEntrance( "cave entry" ):WarpToLocation( self )
	end
end

function OpenHills:GenerateTileMap()
	if self.map == nil then
		self.map = self:GainAspect( Aspect.TileMap( 12, 12 ))
		self.map:FillTiles( function( x, y )
			if self.world:Random() < 0.05 then
				return Tile.Tree( x, y )
			else
				return Tile.Grass( x, y )
			end
		end )
	end
end

