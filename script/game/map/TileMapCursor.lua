local TileMapCursor = class( "TileMapCursor" )

function TileMapCursor:init( map )
	assert( is_instance( map, Aspect.TileMap ))
	self.map = map
end

function TileMapCursor:SetTile( tile_class )
	assert( is_class( tile_class, Tile ))
	self.tile_class = tile_class
	return self
end

-- Move an offset, without painting.
function TileMapCursor:Move( dx, dy )
	self.x, self.y = self.x + dx, self.y + dy
	return self
end

function TileMapCursor:MoveTo( x, y, z )
	self.x, self.y, self.z = x, y, z
	return self
end

-- Paint the current or provided location.
function TileMapCursor:Paint( x, y )
	if self.tile_class then
		local tile = self.tile_class()
		tile:SetCoordinate( x or self.x, y or self.y )
		self.map:ReassignToGrid( tile )
	end
	return self
end

function TileMapCursor:Line( dx, dy )
	return self:LineTo( self.x + dx, self.y + dy )
end

function TileMapCursor:LineTo( x, y )
	while self.x ~= x or self.y ~= y do
		if self.x < x then
			self:MoveTo( self.x + 1, self.y )
		elseif self.x > x then
			self:MoveTo( self.x - 1, self.y )
		end

		if self.y < y then
			self:MoveTo( self.x, self.y + 1 )
		elseif self.y > y then
			self:MoveTo( self.x, self.y - 1 )
		end

		self:Paint()

	end
	return self
end

function TileMapCursor:LinePattern( dx, dy, pattern )
	local n = #pattern
	for i = 1, n do
		local ch = pattern:sub( i, i )

		if ch ~= " " then
			self:Paint()
		end

		self:Move( dx, dy )
	end
	return self
end

-- Cursor is at the bottom-left (min x, min y) of the box.
-- Does not move cursor.
function TileMapCursor:Box( w, h )
	for y = self.y, self.y + h - math.unit( h ), math.unit( h ) do
		for x = self.x, self.x + w - math.unit( w ), math.unit( w ) do
			self:Paint( x, y )
		end
	end
	return self
end

function TileMapCursor:SpawnEntity( ent )
	assert( self.map:LookupTile( self.x, self.y ))
	ent:WarpToLocation( self.map.owner, self.x, self.y )
	return self
end


