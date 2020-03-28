local FieldTileMap = class( "Aspect.FieldTileMap", Aspect.TileMap )

function FieldTileMap:GenerateTileMap()
	self:FillTiles( function( x, y )
		return Tile.Grass( x, y )
	end )
	-- local north = self:FindExit( EXIT.NORTH )
	-- if north then
	-- 	for x = 1, 16 do
	-- 		self.map:LookupGrid( x, 1 ):GainAspect( Aspect.Portal( north, x, 16 ))
	-- 		error()
	-- 	end
	-- end
end

