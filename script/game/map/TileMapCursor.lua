local TileMapCursor = class( "TileMapCursor" )

function TileMapCursor:init( map )
	assert( is_instance( map, Aspect.TileMap ))
	self.map = map
	self.yield_duration = nil --0.001 -- Fixme: doesnt scale properly.
	self.yield_count = 0
end

function TileMapCursor:SetTile( tile_class )
	assert( is_class( tile_class, Tile ))
	self.tile_class = tile_class
	return self
end

function TileMapCursor:SetYield( duration )
	self.yield_duration = duration
end

function TileMapCursor:SetRegionID( region_id )
	self.region_id = region_id
end

function TileMapCursor:GetCoordinate()
	return self.x, self.y
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


function TileMapCursor:FillTiles( w, h, fn )
	for y = 1, h do
		for x = 1, w do
			local tile = fn( x, y, w, h )
			assert( tile )
			self.map:ReassignToGrid( tile )
			self:YieldForTile( tile )
		end
	end
end

function TileMapCursor:YieldForTile( tile )
	if self.yield_duration then
		if self.yield_count == 0 then
			coroutine.yield( YIELD_CMD.LOCATION, self.map.owner )
		end
		self.yield_count = self.yield_count + 1
		coroutine.yield( YIELD_CMD.PAN_TILE, tile, self.yield_duration )
	end
end

-- Paint the current or provided location.
function TileMapCursor:Paint( x, y )
	if self.tile_class then
		local tile = self.tile_class()
		tile:SetCoordinate( x or self.x, y or self.y )
		tile:AssignRegionID( self.region_id )
		self.map:ReassignToGrid( tile )
		self:YieldForTile( tile )
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

local function TileIntersects( x, y, xa, ya, xb, yb, xc, yc, xd, yd )
	-- 𝑀  of coordinates (𝑥,𝑦) is inside the rectangle iff
	-- (0<𝐀𝐌⋅𝐀𝐁<𝐀𝐁⋅𝐀𝐁)∧(0<𝐀𝐌⋅𝐀𝐃<𝐀𝐃⋅𝐀𝐃)

	local amx, amy = x - xa, y - ya
	local abx, aby = xb - xa, yb - ya
	local adx, ady = xd - xa, yd - ya
	local amab = (amx * abx + amy * aby)
	local abab = (abx * abx + aby * aby)
	local amad = (amx * adx + amy * ady)
	local adad = (adx * adx + ady * ady)
	return 0 < amab and amab < abab and 0 < amad and amad < adad
end

function TileMapCursor:ThickLine( w, dx, dy )
	local nx, ny = normalizeVec2( -dy, dx )
	local xa, ya = self.x + nx * w/2, self.y + ny * w/2
	local xb, yb = xa + dx, ya + dy
	local xd, yd = self.x - nx * w/2, self.y - ny * w/2
	local xc, yc = xd + dx, yd + dy

	-- Iterate over the AABB.
	local x1 = math.floor( math.min( xa, xb, xc, xd ) )
	local x2 = math.ceil( math.max( xa, xb, xc, xd ) )
	local y1 = math.floor( math.min( ya, yb, yc, yd ) )
	local y2 = math.ceil( math.max( ya, yb, yc, yd ) )
	for y = y1, y2 do
		for x = x1, x2 do
			if TileIntersects( x, y, xa, ya, xb, yb, xc, yc, xd, yd ) then
				self:MoveTo( x, y )
				self:Paint()
			end
		end
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


