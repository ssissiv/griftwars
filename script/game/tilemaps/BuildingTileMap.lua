local BuildingTileMap = class( "Aspect.BuildingTileMap", Aspect.TileMap )

function BuildingTileMap:GenerateTileMap()
	self:FillTiles( function( x, y )
		if x == 1 or y == 1 or x == self.w or y == self.h then
			return Tile.StoneWall( x, y )
		else
			return Tile.StoneFloor( x, y )
		end
	end )
end

