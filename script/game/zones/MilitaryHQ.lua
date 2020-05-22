local MilitaryHQ = class( "Location.MilitaryHQ", Location )

MilitaryHQ.WORLDGEN_TAGS = { "hq exit" }

function MilitaryHQ:OnSpawn( world )
	Location.OnSpawn( self, world )
	self:SetDetails( "War HQ", "An open room crammed with old tech and metal debris.")
	self:GainAspect( Feature.StrategicPoint() )
	-- self:GainAspect( Aspect.FactionMember( self.faction ))

	Object.Door( "hq exit"):WarpToLocation( self )
end

function MilitaryHQ:GenerateTileMap()
	if self.map == nil then
		self.map = self:GainAspect( Aspect.TileMap( 8, 8 ))
		self.map:FillTiles( function( x, y )
			if x == 1 or x == 8 or y == 1 or y == 8 then
				return Tile.StoneWall( x, y )
			else
				return Tile.StoneFloor( x, y )
			end
		end )
	end
end