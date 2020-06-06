
local JunkYard = class( "Location.JunkYard", Location )

function JunkYard:init()
	Location.init( self )
	self:SetDetails( "Junk Yard" )
end

function JunkYard:GenerateTileMap()
	if self.map == nil then
		self.map = self:GainAspect( Aspect.TileMap( 24, 24 ))
		self.map:FillTiles( function( x, y )
			return Tile.DirtFloor( x, y )
		end )

		local cursor = self.map:CreateCursor( 8, 12 ):SetTile( Tile.StoneWall )
		cursor:Line( 8, 0 )
	end
end
