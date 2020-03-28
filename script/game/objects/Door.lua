local Door = class( "Object.Door", Object )

Door.image = assets.TILE_IMG.DOOR
print( Door.image )
function Door:GetName()
	return "Door"
end

function Door:RenderMapTile( screen, tile, x1, y1, x2, y2 )
	local sx, sy = (x2 - x1) / self.image:getWidth(), (y2 - y1) / self.image:getHeight()
	love.graphics.setColor( 255, 255, 255, 255 )
	screen:Image( self.image, x1, y1, sx, sy )
end
