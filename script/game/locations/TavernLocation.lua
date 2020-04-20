
local TavernTileMap = class( "Aspect.TavernTileMap", Aspect.TileMap )

function TavernTileMap:GenerateTileMap()
	self:FillTiles( function( x, y )
		if x == 1 or y == 1 or x == self.w or y == self.h then
			return Tile.StoneWall( x, y )
		else
			return Tile.WoodenFloor( x, y )
		end
	end )
end

----------------------------------------------------------------------------------------------

local TavernLocation = class( "Location.Tavern", Location )

function TavernLocation:init()
	Location.init( self )
	self:SetImage( assets.LOCATION_BGS.SHOP )
	self:GainAspect( Aspect.TavernTileMap( 8, 8 ))
	local shop = self:GainAspect( Feature.Shop( table.pick( SHOP_TYPE )))
end