local TileMapCursor = class( "TileMapCursor" )

function TileMapCursor:init( map )
	assert( is_instance( map, Aspect.TileMap ))
	self.map = map
	self.w, self.h = map:GetExtents()
end

function TileMapCursor:SetCoord( x, y, z )
	self.x, self.y, self.z = x, y, z
	return self
end

function TileMapCursor:SetTile( tile_class )
	assert( is_class( tile_class, Tile ))
	self.tile_class = tile_class
	return self
end

function TileMapCursor:Move( dx, dy )
	self.x, self.y = self.x + dx, self.y + dy
	return self
end

-- Paints a single tile at x, y.
-- Does not move cursor.
function TileMapCursor:Point( x, y )
	if self.tile_class then
		local tile = self.tile_class()
		tile:SetCoordinate( x, y )
		self.map:ReassignToGrid( tile )
	end
end

function TileMapCursor:LineTo( x, y )
	while self.x ~= x or self.y ~= y do
		if self.x < x then
			self.x = self.x + 1
		elseif self.x > x then
			self.x = self.x - 1
		end

		if self.y < y then
			self.y = self.y + 1
		elseif self.y > y then
			self.y = self.y - 1
		end

		if self.tile_class then
			self:Point( self.x, self.y )
		end
	end
	return self
end

function TileMapCursor:LinePattern( dx, dy, pattern )
	local n = #pattern
	for i = 1, n do
		local ch = pattern:sub( i, i )

		if self.tile_class and ch ~= " " then
			self:Point( self.x, self.y )
		end

		self.x = self.x + dx
		self.y = self.y + dy
	end
end

-- Cursor is at the bottom-left (min x, min y) of the box.
-- Does not move cursor.
function TileMapCursor:Box( w, h )
	for y = self.y, self.y + h - math.unit( h ) do
		for x = self.x, self.x + w - math.unit( w ) do
			self:Point( x, y )
		end
	end
end

