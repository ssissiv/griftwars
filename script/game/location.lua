
local function SpawnLocation( location, world )
	if location:IsSpawned() then
		return false
	else
		world:SpawnLocation( location )
		return true
	end
end


local Location = class( "Location", Entity )

function Location:init()
	Entity.init( self )
	self.exits = {}
	self.portals = {}
	self.available_exits = { EXIT.NORTH, EXIT.EAST, EXIT.SOUTH, EXIT.WEST }
	self.map_colour = constants.colours.DEFAULT_TILE
end

function Location:OnSpawn( world )
	Entity.OnSpawn( self, world )

	if self.contents then
		for i, v in ipairs( self.contents ) do
			if not v:IsSpawned() then
				world:SpawnEntity( v )
			end
		end
	end

	for i, exit in pairs( self.exits ) do
		local dest, addr = exit:GetDest( self )
		if IsEnum( addr, EXIT ) then
			local x, y = OffsetExit( dest.x, dest.y, REXIT[ addr ] )
			if self.x == nil or self.y == nil then
				self.x, self.y = x, y
			else
				assert( self.x == x and self.y == y )
			end
		end
	end

	if self.x and self.y then
		world:GetAspect( Aspect.TileMap ):AssignToGrid( self )
	end
end

function Location:OnDespawn()
	Entity.OnDespawn( self )

	if self.x and self.y then
		self.world:GetAspect( Aspect.TileMap ):UnassignFromGrid( self )
	end
end


function Location:LocTable()
	return self
end

function Location:SetCoordinate( x, y, z )
	if self.x then
		world:GetAspect( Aspect.TileMap ):UnassignFromGrid( self )
	end

	self.x = x
	self.y = y
	self.z = z

	if self.world and self.x and self.y then
		world:GetAspect( Aspect.TileMap ):AssignToGrid( self )
	end		
end

function Location:GetCoordinate()
	return self.x, self.y, self.z
end

function Location:SetImage( image )
	self.image = image
end

function Location:GetImage( image )
	return self.image
end

function Location:SetDetails( title, desc )
	self.title = title
	self.desc = desc
end


function Location:AddEntity( entity )
	assert( is_instance( entity, Entity ))
	assert( self.contents == nil or table.arrayfind( self.contents, entity ) == nil )
	assert( entity.location == self )
	
	if self.contents == nil then
		self.contents = {}
	end

	table.insert( self.contents, entity )

	if is_instance( entity, Agent ) then
		self:BroadcastEvent( LOCATION_EVENT.AGENT_ADDED, entity )
	end

	-- Spawn entity or self, if needed.
	if entity.world == nil and self.world then
		self.world:SpawnEntity( entity )		
	elseif entity.world and self.world == nil then
		SpawnLocation( self, entity.world )
	end
	
	entity:ListenForAny( self, self.OnEntityEvent )

	if self.map then
		self:PlaceEntity( entity )

	elseif is_instance( entity, Agent ) and entity:IsPuppet() then
		self:GenerateTileMap()

	else
		assert( entity:GetCoordinate() == nil )
	end
end

function Location:RemoveEntity( entity )
	local idx = table.arrayfind( self.contents, entity )
	table.remove( self.contents, idx )

	entity:RemoveListener( self )

	if is_instance( entity, Agent ) then
		self:BroadcastEvent( LOCATION_EVENT.AGENT_REMOVED, entity )

		if entity:IsPuppet() then
			self:DisposeReality()
		end
	end

	if self.map then
		local x, y  = entity:GetCoordinate()
		local tile = self.map:LookupGrid( x, y )
		tile:RemoveEntity( entity )
	end

	entity:SetCoordinate( nil, nil )
end

function Location:AddAgent( agent )
	assert( is_instance( agent, Agent ))
	self:AddEntity( agent )
end

function Location:RemoveAgent( agent )
	assert( is_instance( agent, Agent ))
	self:RemoveEntity( agent )
end

function Location:HasEntity( ent )
	for i, obj in ipairs( self.contents ) do
		if obj == ent then
			return true
		end
		if is_class( ent ) and is_instance( obj, ent ) then
			return true
		end
	end
	return false
end

function Location:OnEntityEvent( event_name, entity, ... )
	for i, obj in ipairs( self.contents ) do
		if entity ~= obj and obj.OnLocationEntityEvent then
			obj:OnLocationEntityEvent( event_name, entity, ... )
		end
	end
end


function Location:IsConnected( other )
	return table.find( self.exits, other ) ~= nil
end


function Location:Connect( other, addr )
	assert( other ~= nil )
	assert( is_instance( other, Location ))
	assert( not self:FindExit( addr ))

	local exit = Exit()

	if IsEnum( addr, EXIT ) then
		local raddr = REXIT[ addr ]
		assert( not other:FindExit( raddr ))

		table.arrayremove( self.available_exits, addr )
		table.arrayremove( other.available_exits, raddr )

		exit:Connect( self, addr, other, raddr )
	
	else
		exit:Connect( self, addr, other, addr )
	end


	table.insert( self.exits, exit )
	table.insert( other.exits, exit )

	if not self:IsSpawned() and other:IsSpawned() then
		self:Visit( SpawnLocation, other.world, self )
	elseif self:IsSpawned() and not other:IsSpawned() then
		other:Visit( SpawnLocation, self.world, self )
	end

	return exit
end

function Location:FindExit( addr )
	for i, exit in ipairs( self.exits ) do
		local dest, dest_addr = exit:GetDest( self )
		if dest_addr == addr then
			return exit
		end
	end
end

function Location:Exits()
	return ipairs( self.exits )
end

local function VisitInternal( visited, location, fn, ... )
	visited[ location ] = true
	if not fn( location, ... ) then
		return
	end

	for i, exit in ipairs( location.exits ) do
		local dest = exit:GetDest( location )
		assert( dest )
		if visited[ dest ] == nil then
			VisitInternal( visited, dest, fn, ... )
		end
	end
end

-- Depth-first traversal applying fn().
function Location:Visit( fn, ... )
	VisitInternal( {}, self, fn, ... )
end

function Location:Portals()
	return ipairs( self.portals )
end

function Location:AddPortal( portal )
	table.insert( self.portals, portal )
end

function Location:RemovePortal( portal )
	table.arrayremove( self.portals, portal )
end

-- Breadth-first traversal applying fn().
-- fn( location, depth ) returns two booleans:
--		continue: if false, do not flood from this location
--		stop: abort the Flood search entirely.

function Location:Flood( fn, ... )
	local open, closed = { self, 0 }, {}

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
			for i, exit in ipairs( x.exits ) do
				local dest = exit:GetDest( x )
				if not table.contains( open, dest ) and not table.contains( closed, dest ) then
					table.insert( open, dest )
					table.insert( open, depth + 1 )
				end
			end
		end
	end

	assert_warning( #closed <= 99, "Floodings lots of rooms!", #closed )
end

function Location:SearchObject( fn, max_depth )
	local candidates = {}
	local open, closed = { self }, { [self] = 0 }
	local depth = 0

	max_depth = max_depth or math.huge

	while depth <= max_depth and #open > 0 do

		local x = table.remove( open )
		depth = closed[ x ]

		-- search contents
		if x.contents then
			for i, obj in ipairs( x.contents ) do
				if fn( obj ) then
					table.insert( candidates, obj )
				end
			end
		end

		if depth < max_depth then
			-- recurse
			for i, exit in ipairs( x.exits ) do
				local dest = exit:GetDest( x )
				if not table.contains( open, dest ) and not closed[ dest ] then
					table.insert( open, dest )
					closed[ dest ] = depth + 1
				end
			end
		end
	end

	return candidates
end

function Location:FindPassableTile( x, y, obj )
	local found_tile
	local function IsPassable( tile, depth, obj )
		if tile:HasEntity( obj ) then
			-- Already at this tile, exclude it.
			return true 
		elseif tile:IsPassable( obj ) then
			-- Found a tile passable by this object.
			found_tile = tile
			return false, true -- STOP
		end
		return true
	end

	local origin = self:GetTileAt( x, y )
	assert( origin )

	self.map:Flood( origin, IsPassable, obj )

	return found_tile
end

function Location:Contents()
	return ipairs( self.contents or table.empty )
end

function Location:GetTitle()
	if type(self.title) == "function" then
		return self.title( self )
	else
		return self.title or tostring(self._classname)
	end
end

function Location:GetDesc()
	return self.desc or "No Desc"
end

function Location:GenerateTileMap()
	if self.map then
		return
	end

	self.map = self:GetAspect( Aspect.TileMap )
	if self.map == nil then
		self.map = self:GainAspect( Aspect.TileMap( 8, 8 ))
	end
	self.map:GenerateTileMap()

	for i, obj in self:Contents() do
		local x, y = obj:GetCoordinate()
		local tile = x and y and self.map:LookupGrid( x, y )
		if tile then
			tile:AddEntity( obj )
		else
			self:PlaceEntity( obj )
		end
	end
end

function Location:FindPortalTiles()
	return self.map:FindTiles( function( tile ) return tile:HasAspect( Aspect.Portal ) end )
end


function Location:PlaceEntity( obj )
	local x, y = obj:GetCoordinate()
	print( "Place", obj, self, x, y )
	if not x then
		local w, h = self.map:GetExtents()
		x, y = math.random( w ), math.random( h )
	end
	local tile = self:FindPassableTile( x, y, obj )
	if not tile then
		assert_warning( tile, string.format( "No tile at: %d, %d", x, y ))
	else
		obj:SetCoordinate( tile.x, tile.y )
		tile:AddEntity( obj )
	end
end

function Location:DisposeReality()
	if self.map then
		self.map:ClearTileMap()
		self.map = nil
	end
end

function Location:GetTileAt( tx, ty )
	if self.map then
		return self.map:LookupGrid( tx, ty )
	end
end

function Location:RenderLocationOnMap( screen, x1, y1, x2, y2 )
	local w, h = x2 - x1, y2 - y1

	love.graphics.setColor( table.unpack( self.map_colour ))
	screen:Rectangle( x1 + 4, y1 + 4, w - 8, h - 8 )

	if self.contents then
		local sz = math.floor( w / 8 )
		local margin = math.ceil( sz / 2 )
		local x, y = x1 + 4 + margin , y1 + 4 + margin
		for i, obj in ipairs( self.contents ) do
			if is_instance( obj, Agent ) then
				love.graphics.setColor( 255, 0, 255 )
			else
				love.graphics.setColor( 255, 255, 0 )
			end

			screen:Rectangle( x, y, sz, sz )
			x = x + sz + margin
			if x >= x2 - margin - 4 then
				x, y = x1 + 4 + margin, y + sz + margin
			end
		end
	end

	love.graphics.setColor( table.unpack( self.map_colour ))

	local exit_sz = math.floor( w / 6 ) -- width of exit
	for i, exit in pairs( self.exits ) do
		local dest, addr = exit:GetDest( self )
		if IsEnum( addr, EXIT ) then
			local x, y = OffsetExit( self.x, self.y, addr )
			if x == dest.x and y == dest.y then
				if addr == EXIT.NORTH then
					screen:Rectangle( x1 + (w - exit_sz) / 2, y2 - 4, exit_sz, 4 )
				elseif addr == EXIT.EAST then
					screen:Rectangle( x2 - 4, y1 + (h - exit_sz) / 2, 4, exit_sz )
				elseif addr == EXIT.WEST then
					screen:Rectangle( x1, y1 + (h - exit_sz) / 2, 4, exit_sz )
				elseif addr == EXIT.SOUTH then
					screen:Rectangle( x1 + (w - exit_sz) / 2, y1, exit_sz, 4 )
				end
			else

			end
		end
	end
end

function Location:__tostring()
	return string.format( "[%s]", self:GetTitle())
end


