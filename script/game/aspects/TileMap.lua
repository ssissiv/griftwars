local TileMap = class( "Aspect.TileMap", Aspect )

function TileMap:init()
	self:ClearTileMap()
end

function TileMap:GetExtents( z )
	local ymin, ymax, xmin, xmax = math.huge, -math.huge, math.huge, -math.huge

	if z == nil then
		for z, layer in pairs( self.layers ) do
			local xmin_layer, ymin_layer, xmax_layer, ymax_layer = self:GetExtents( z )
			ymin, ymax = math.min( ymin, ymin_layer ), math.max( ymax, ymax_layer )
			xmin, xmax = math.min( xmin, xmin_layer ), math.max( xmax, xmax_layer )
		end

	else
		local layer = self.layers[ z ]
		if layer then
			for y, row in pairs( layer ) do
				ymin, ymax = math.min( ymin, y ), math.max( ymax, y )
				for x, tile in pairs( row ) do
					xmin, xmax = math.min( xmin, x ), math.max( xmax, x )
				end
			end
		end
	end

	return xmin, ymin, xmax, ymax
end

function TileMap:ClearTileMap()
	self.layers = { [0] = {} } -- array of arrays.
	self.max_depth = 0
	self.tile_count = 0
end

function TileMap:GenerateTileMap()
	self:FillTiles( function( x, y )
		return Tile.Void( x, y )
	end )
end

function TileMap:CreateCursor( x, y )
	local cursor = TileMapCursor( self )
	cursor:MoveTo( x or 1, y or 1 )
	return cursor
end

function TileMap:GetMaxDepth()
	return self.max_depth
end

local function IterateNeighbours( state, i )
	local tile
	local exit = EXIT_ARRAY[ state.exit_idx ]
	while not tile and exit do
		local x, y = OffsetExit( state.tile.x, state.tile.y, exit )
		tile = state.map:LookupTile( x, y )
		state.exit_idx = state.exit_idx + 1
		exit = EXIT_ARRAY[ state.exit_idx ]
	end
	if tile then
		return (i or 0) + 1, tile
	end
end

function TileMap:Neighbours( tile )
	return IterateNeighbours, { map = self, tile = tile, exit_idx = 1 }
end

function TileMap:FindTiles( fn )
	local tiles = {}
	for z, layer in pairs( self.layers ) do
		for i, row in pairs( layer ) do
			for j, tile in pairs( row ) do
				if fn( tile ) then
					table.insert( tiles, tile )
				end
			end
		end
	end
	return tiles
end

function TileMap:FillTiles( w, h, fn )
	for y = 1, h do
		for x = 1, w do
			local tile = fn( x, y, w, h )
			assert( tile )
			self:AssignToGrid( tile )
		end
	end
end

function TileMap:AssignToGrid( location )
	local x, y, z = location:GetCoordinate()
	local layer = self.layers[ z or 0 ]
	if layer == nil then
		layer = {}
		self.layers[ z ] = layer
		self.max_depth = math.max( self.max_depth, z )
	end

	local row = layer[ y ]
	if row == nil then
		row = {}
		layer[ y ] = row
	end

	if row[ x ] == nil then
		row[ x ] = location
	elseif is_instance( row[ x ] ) then
		row[ x ] = { row[ x ], location }
		error( string.format( "%d, %d, %d: %s (%s already here)", x, y, z, location, row[ x ][1] ))
	else
		table.insert( row[ x ], location )
	end
	self.tile_count = self.tile_count + 1
end

function TileMap:ReassignToGrid( tile )
	local x, y, z = tile:GetCoordinate()
	local prev_tile = self:LookupTile( x, y, z )
	if prev_tile then
		-- tile.contents = prev_tile.contents
		-- prev_tile.contents = nil

		self:UnassignFromGrid( prev_tile )
	end
	self:AssignToGrid( tile )
end


function TileMap:UnassignFromGrid( location )
	local x, y, z = location:GetCoordinate()
	local layer = self.layers[ z or 0 ]
	local t = layer[ y ][ x ]

	for i, obj in t:Contents() do
		obj:Despawn()
	end

	self.tile_count = self.tile_count - 1

	if t == location then
		layer[ y ][ x ] = nil
	elseif t then
		table.arrayremove( t, location )
		if #t == 1 then
			layer[ y ][ x ] = t[ 1 ]
		elseif #t == 0 then
			layer[ y ][ x ] = nil
		end
	else
		error( location )
	end
end

function TileMap:GetRandomTile()
	local n = math.random( 1, self.tile_count )
	assert( self.tile_count > 1 )
	local i = n
	for z, layer in pairs( self.layers ) do
		for y, row in pairs( layer ) do
			for x, tile in pairs( row ) do
				if i == 1 then
					return tile
				else
					i = i - 1
				end
			end
		end
	end
end

function TileMap:AccumulateColumn( x, z )
	local tiles = {}
	local layer = self.layers[ z or 0 ]
	for y, row in pairs( layer ) do
		for x2, tile in pairs( row ) do
			if x2 == x then
				table.insert( tiles, tile )
			end
		end
	end
	return tiles
end

function TileMap:AccumulateRow( y, z )
	local tiles = {}
	local layer = self.layers[ z or 0 ]
	for y2, row in pairs( layer ) do
		if y2 == y then
			for x, tile in pairs( row ) do
				table.insert( tiles, tile )
			end
			break
		end
	end
	return tiles or table.empty
end

function TileMap:LookupTile( x, y, z )
	local layer = self.layers[ z or 0 ]
	if layer == nil then
		return nil
	end

	local row = layer[ y ]
	if row then
		return row[ x ]
	end
end

-- Breadth-first traversal applying fn().
-- fn( location, depth ) returns two booleans:
--		continue: if false, do not flood from this location
--		stop: abort the Flood search entirely.

function TileMap:Flood( origin, fn, ... )
	assert( self:LookupTile( origin:GetCoordinate() ) == origin )

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
				local x, y, z = x:GetCoordinate()
				x, y = OffsetExit( x, y, exit )
				local ntile = self:LookupTile( x, y, z )
				if ntile and not table.contains( open, ntile ) and not table.contains( closed, ntile ) then
					table.insert( open, ntile )
					table.insert( open, depth + 1 )
				end
			end
		end
	end

	assert_warning( #closed <= 99, "Floodings lots of tiles!", #closed )
end

function TileMap:RenderDebugPanel( ui, panel )
	ui.Text( "HI" )
end

function TileMap:__serialize()
	local dense_tiles, tiles = {}, {}
	for z, layer in pairs( self.layers ) do
		dense_tiles[ z ] = {}
		for y, row in pairs( layer ) do
			for x, tile in pairs( row ) do
				if tile.contents or tile.aspects then
					table.insert( tiles, tile )
				else
					local coords = dense_tiles[ tile._classname ]
					if coords == nil then
						coords = {}
						dense_tiles[ tile._classname ] = coords
					end
					table.insert( coords, x )
					table.insert( coords, y )
					table.insert( coords, z )
				end
			end
		end
	end

	local t =
	{
		_classname = self._classname,
		owner = self.owner,
		xmin = self.xmin,
		ymin = self.ymin,
		xmax = self.xmax,
		ymax = self.ymax,
		tiles = tiles,
		dense_tiles = dense_tiles,
	}

	return t
end



