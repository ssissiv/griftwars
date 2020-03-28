local TileMap = class( "Aspect.TileMap", Aspect )

function TileMap:init( w, h )
	self.grid = {} -- array of arrays.
	self.w, self.h = w or 10, h or 10
end

function TileMap:GetExtents()
	return self.w, self.h
end

function TileMap:GenerateTileMap()
	self:FillTiles( function( x, y )
		return Tile.Grass( x, y )
	end )
end

function TileMap:FindTiles( fn )
	local tiles = {}
	for i, row in pairs( self.grid ) do
		for j, tile in pairs( row ) do
			if fn( tile ) then
				table.insert( tiles, tile )
			end
		end
	end
	return tiles
end

function TileMap:FillTiles( fn )
	for y = 1, self.h do
		for x = 1, self.w do
			local tile = fn( x, y )
			assert( tile )
			self:AssignToGrid( tile )
		end
	end
end

function TileMap:AssignToGrid( location )
	local x, y = location:GetCoordinate()

	local row = self.grid[ y ]
	if row == nil then
		row = {}
		self.grid[ y ] = row
	end

	if row[ x ] == nil then
		row[ x ] = location
	elseif is_instance( row[ x ] ) then
		row[ x ] = { row[ x ], location }
		error()
	else
		table.insert( row[ x ], location )
	end
end

function TileMap:UnassignFromGrid( location )
	local x, y = location:GetCoordinate()
	local t = self.row[ y ][ x ]
	if t == location then
		self.row[ y ][ x ] = nil
	elseif t then
		table.arrayremove( t, location )
		if #t == 1 then
			self.row[ y ][ x ] = t[ 1 ]
		elseif #t == 0 then
			self.row[ y ][ x ] = nil
		end
	else
		error( location )
	end
end

function TileMap:LookupGrid( x, y )
	local row = self.grid[ y ]
	if row then
		local t = row[ x ]
		if is_instance( t ) then
			return t
		elseif t then
			return t[1]
		end
	end
end

-- Breadth-first traversal applying fn().
-- fn( location, depth ) returns two booleans:
--		continue: if false, do not flood from this location
--		stop: abort the Flood search entirely.

function TileMap:Flood( origin, fn, ... )
	assert( self:LookupGrid( origin:GetCoordinate() ) == origin )

	local open, closed = { origin, 0 }, {}

	while #open > 0 do
		local x = table.remove( open, 1 )
		local depth = table.remove( open, 1 )

		table.insert( closed, x )
		if #closed > 999 then
			break
		end

		local continue, stop = fn( x, depth, ... )
		if stop then
			break
		elseif continue then
			for i, exit in ipairs( EXIT_ARRAY ) do
				local x, y = x:GetCoordinate()
				x, y = OffsetExit( x, y, exit )
				local ntile = self:LookupGrid( x, y )
				if ntile and not table.contains( open, ntile ) and not table.contains( closed, ntile ) then
					table.insert( open, ntile )
					table.insert( open, depth + 1 )
				end
			end
		end
	end

	assert_warning( #closed <= 99, "Floodings lots of tiles!", #closed )
end


