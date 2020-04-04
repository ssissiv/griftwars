local FieldTileMap = class( "Aspect.FieldTileMap", Aspect.TileMap )

function FieldTileMap:GenerateTileMap()
	self:FillTiles( function( x, y )
		return Tile.Grass( x, y )
	end )
end

