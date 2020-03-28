local BuildingTileMap = class( "Aspect.BuildingTileMap", Aspect.TileMap )

function BuildingTileMap:GenerateTileMap()
	self:FillTiles( function( x, y )
		if x == 1 or y == 1 or x == self.w or y == self.h then
			return Tile.StoneWall( x, y )
		else
			return Tile.StoneFloor( x, y )
		end
	end )

	-- local tile = self:LookupGrid( math.random( self.w - 2 ) + 1, self.random( self.h - 2 ) + 1 )
	-- local north = self:FindExit( EXIT.NORTH )
	-- if north then
	-- 	for x = 1, 16 do
	-- 		self.map:LookupGrid( x, 1 ):GainAspect( Aspect.Portal( north, x, 16 ))
	-- 		error()
	-- 	end
	-- end
end

