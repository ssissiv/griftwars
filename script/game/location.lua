
local function SpawnLocation( location, world )
	if location:IsSpawned() then
		return false
	else
		world:SpawnLocation( location )
		return true
	end
end


local Location = class( "Location", Entity )

function Location:init( zone, gen_portal )
	Entity.init( self )
	self.zone = zone
	self.gen_portal = gen_portal
	self.portals = {}
	self.waypoints = {}
end

function Location:OnSpawn( world )
	Entity.OnSpawn( self, world )

	self.rng = self:GainAspect( Aspect.Rng() )

	self:GenerateTileMap()

	if self.contents then
		for i, obj in ipairs( self.contents ) do		
			local x, y = obj:GetCoordinate()
			local tile = x and y and self.map:LookupTile( x, y )
			if not tile or not tile:HasEntity( obj ) then -- could be added during GenerateTileMap().
				if tile then
					tile:AddEntity( obj )
				else
					self:PlaceEntity( obj )
				end
			end
			if not obj:IsSpawned() then
				world:SpawnEntity( obj )
			end
		end
	end
end

function Location:OnDespawn()
	if self.contents then
		for i, obj in ipairs( self.contents ) do 
			self.world:DespawnEntity( obj )
		end
	end

	if self.x and self.y then
		self.world:GetAspect( Aspect.TileMap ):UnassignFromGrid( self )
	end

	Entity.OnDespawn( self )
end

function Location:GenerateLocTable( viewer )
	local t = { viewer = viewer }

	t.title = self:GetTitle()
	
	t.udesc = self.title .. "(Unexplored)"
	t.Udesc = loc.cap( t.udesc )

	if self:IsDiscovered( viewer ) then
		t.desc = t.title
	else
		t.desc = t.udesc
	end

	t.Desc = loc.cap( t.desc )

	t.id = t.desc
	t.Id = t.Desc

	return t
end


function Location:LocTable( viewer )
	if viewer == nil and self.world then
		viewer = self.world:GetPuppet()
	end

	if self.loc_table == nil or self.loc_table.viewer ~= viewer then
		self.loc_table = self:GenerateLocTable( viewer )
	end
	return self.loc_table
end

function Location:AssignZone( zone, depth )
	assert( is_instance( zone, Zone ))
	self.zone = zone
	self.location_depth = depth
end

function Location:GetZone()
	return self.zone
end

-- How many locations from the origin Location (Location that generated this zone)
function Location:GetLocationDepth()
	return self.location_depth
end

function Location:GetCoordinate()
	return self.x, self.y, self.z
end

function Location:SetCoordinate( x, y, z )
	if self.x then
		self.world:GetWorldMap():UnassignFromGrid( self )
	end

	self.x = x
	self.y = y
	self.z = z or 0

	if self.world and self.x and self.y then
		self.world:GetWorldMap():AssignToGrid( self )
	end		
end

function Location:GetWaypoint( id )
	return self.waypoints[ id ]
end

function Location:SetWaypoint( id, waypoint )
	self.waypoints[ id ] = waypoint
end

function Location:SetDetails( title, desc )
	if title then
		self.title = title
	end
	if desc then
		self.desc = desc
	end
end

-- Spawns a portal on the perimter of this Location's TileMap with the given 'tag'.
function Location:SpawnPerimeterPortal( tag, exit_tag )
	local portal = Object.Portal( tag .. " " .. exit_tag )
	local w, h = self.map:GetExtents()
	if exit_tag == "east" then
		portal:WarpToLocation( self, w, math.floor(h/2) )
	elseif exit_tag == "west" then
		portal:WarpToLocation( self, 1, math.floor(h/2) )
	elseif exit_tag == "south" then
		portal:WarpToLocation( self, math.floor(w/2), 1 )
	elseif exit_tag == "north" then
		portal:WarpToLocation( self, math.floor(w/2), h )
	else
		error( exit_tag )
	end
end

-- Randomly spawns portals on the perimeter, one for each cardinal direction.
-- If there is a 'gen_portal' assigned, there is guaranteed to be a perimeter
-- portal that matches it for future connectivity.
function Location:SpawnPerimeterPortals( tag )
	local w, h = self.map:GetExtents()
	local exits = self.world:Shuffle{ EXIT.EAST, EXIT.WEST, EXIT.NORTH, EXIT.SOUTH }
	local n = self.rng:Random( 1, 4 )
	for i = 1, 4 do
		local exit = exits[i]
		local exit_tag = EXIT_TAG[ exit ]
		local portal
		-- We are connecting to this direction: must include it.
		if self.gen_portal and self.gen_portal:HasWorldGenTag( MATCH_TAGS[ exit_tag ] ) then
			local t1 = self.gen_portal:GetWorldGenTag():gsub( MATCH_TAGS[ exit_tag ], "" )
			self:SpawnPerimeterPortal( t1, exit_tag )

		elseif i <= n then
			if self.location_depth >= self.zone:GetMaxDepth() then
				self:SpawnPerimeterPortal( "boundary", exit_tag )
			else
				self:SpawnPerimeterPortal( tag, exit_tag )
			end
		end
	end
end


function Location:AddEntity( entity )
	assert( is_instance( entity, Entity ))
	assert( self.contents == nil or table.arrayfind( self.contents, entity ) == nil )
	assert( entity.location == self )
	
	if self.contents == nil then
		self.contents = {}
	end

	table.insert( self.contents, entity )

	-- Spawn entity or self, if needed.
	if entity.world == nil and self.world then
		self.world:SpawnEntity( entity )		
	elseif entity.world and self.world == nil then
		error( "This seems dumb" )
		SpawnLocation( self, entity.world )
	end
	
	entity:ListenForAny( self, self.OnEntityEvent )

	if is_instance( entity, Agent ) then
		self:BroadcastEvent( LOCATION_EVENT.AGENT_ADDED, entity )

		if not entity:IsPuppet() and table.contains( self.contents, self.world:GetPuppet() ) then
			-- self.world:ScheduleInterrupt( 0, loc.format( "{1.Id} appears ({2})", entity:LocTable(), rawstring(entity)) )
		end
	end

	if self.map then
		self:PlaceEntity( entity )

	elseif is_instance( entity, Agent ) and entity:IsPuppet() then
		error( "don't think this happens anymore" )
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
		local tile = self.map:LookupTile( x, y )
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
	-- DEPRECATED?
	for i, obj in ipairs( self.contents ) do
		if entity ~= obj and obj.OnLocationEntityEvent then
			obj:OnLocationEntityEvent( event_name, entity, ... )
		end
	end

	-- Forward this event to anyone listening to this location.
	self:BroadcastEvent( event_name, entity, ... )
end

local function VisitInternal( visited, location, fn, ... )
	visited[ location ] = true
	if not fn( location, ... ) then
		return
	end

	for i, portal in ipairs( location.portals ) do
		local dest = portal:GetDest( location )
		assert( dest )
		if visited[ dest ] == nil then
			VisitInternal( visited, dest, fn, ... )
		end
	end
end

function Location:IsDiscovered( viewer )
	if viewer == nil then
		return true
	end
	
	if DBGFLAG( DBG_FLAGS.GOD ) then
		return true
	end

	return viewer:GetMemory():HasEngram( function( engram ) return is_instance( engram, Engram.Discovered ) and engram.target == self end )
end

function Location:Discover( agent )
	agent:GetMemory():AddEngram( Engram.Discovered( self ))
end


-- Depth-first traversal applying fn().
function Location:Visit( fn, ... )
	VisitInternal( {}, self, fn, ... )
end

function Location:Portals()
	return ipairs( self.portals )
end

function Location:AddPortal( portal )
	assert( not table.contains( self.portals, portal ))
	table.insert( self.portals, portal )
end

function Location:RemovePortal( portal )
	table.arrayremove( self.portals, portal )
end

function Location:FindPortalTo( dest )
	for i, portal in ipairs( self.portals ) do
		if portal:GetDest() == dest then
			return portal
		end
	end
end

function Location:FindPortalWithTag( tag )
	for i, portal in ipairs( self.portals ) do
		if portal:HasWorldGenTag( tag ) then -- and portal:GetDest() then
			return portal
		end
	end
end

function Location:GetBoundaryPortal( exit )
	for i, portal in ipairs( self.portals ) do
		if portal:HasWorldGenTag( "boundary" ) and (exit == nil or portal:HasWorldGenTag( EXIT_TAG[ exit ] )) then
			return portal
		end
	end
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
			for i, portal in ipairs( x.portals ) do
				local dest = portal:GetDest( x )
				if dest and not table.contains( open, dest ) and not table.contains( closed, dest ) then
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
			for i, portal in ipairs( x.portals ) do
				local dest = portal:GetDest( x )
				if not table.contains( open, dest ) and not closed[ dest ] then
					table.insert( open, dest )
					closed[ dest ] = depth + 1
				end
			end
		end
	end

	return candidates
end

function Location:FindEmptyPassableTile( x, y, obj )
	local found_tile
	local function IsEmptyPassable( tile, depth, obj )
		if tile:IsEmpty() and tile:IsPassable( obj )then
			found_tile = tile
			return false, true -- STOP
		end
		return true
	end

	local origin = x and self:LookupTile( x, y ) or self.map:GetRandomTile()
	assert( origin, tostring(x)..","..tostring(y) )

	self.map:Flood( origin, IsEmptyPassable, obj )

	return found_tile
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

	local origin = self:LookupTile( x, y )
	assert( origin, tostring(x)..","..tostring(y) )

	self.map:Flood( origin, IsPassable, obj )

	return found_tile
end

function Location:Contents()
	return ipairs( self.contents or table.empty )
end

function Location:FindEntity( pred )
	for i, obj in ipairs( self.contents ) do
		if pred( obj ) then
			return obj
		end
	end
end

function Location:FindInscribedEntity( txt )
	for i, obj in ipairs( self.contents ) do
		if obj:IsInscribed( txt ) then
			return obj
		end
	end
end

function Location:GetTitle()
	local title
	if type(self.title) == "function" then
		title = self.title( self ) or ""
	else
		title = self.title or tostring(self._classname)
	end

	if self.zone then
		title = loc.format( "{1} ({2})", title, self.zone:GetName())
	end
	return title
end

function Location:GetDesc()
	return self.desc or "No Desc"
end

function Location:GenerateTileMap()
	if self.map == nil then
		self.map = self:GetAspect( Aspect.TileMap )
		if self.map == nil then
			self.map = self:GainAspect( Aspect.TileMap( 8, 8 ))
		end
		self.map:GenerateTileMap()

	end

	return self.map
end

function Location:PlaceEntity( obj )
	local x, y = obj:GetCoordinate()
	if not x then
		-- print( "Place", obj, self, x, y )
		local w, h = self.map:GetExtents()
		x, y = self.rng:Random( w ), self.rng:Random( h )
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
	-- if self.map then
	-- 	self.map:ClearTileMap()
	-- 	self.map = nil
	-- end
end

function Location:LookupTile( tx, ty )
	if self.map then
		return self.map:LookupTile( tx, ty )
	end
end

function Location:RenderLocationOnMap( screen, x1, y1, x2, y2, viewer )
	if not self:IsDiscovered( viewer ) then
		for i, portal in ipairs( self.portals ) do
			if portal:GetDest() and portal:GetDest():IsDiscovered( viewer ) then
				local w, h = x2 - x1, y2 - y1
				screen:SetColour( constants.colours.WHITE )
				screen:Image( assets.IMG.UNKNOWN_LOCATION, x1, y1, w, h )
			end
		end

	else
		local w, h = x2 - x1, y2 - y1
		local map_colour = self.map_colour or (self.zone and self.zone.ZONE_COLOUR) or constants.colours.DEFAULT_TILE

		love.graphics.setColor( table.unpack( map_colour ))
		screen:Rectangle( x1 + 4, y1 + 4, w - 8, h - 8 )

		if self.contents then
			local sz = math.floor( w / 8 )
			local margin = math.ceil( sz / 2 )
			local x, y = x1 + 4 + margin , y1 + 4 + margin
			for i, obj in ipairs( self.contents ) do
				local skip = false
				if is_instance( obj, Agent ) then
					love.graphics.setColor( 255, 0, 255 )
				elseif obj:HasAspect( Aspect.Portal ) then
					if obj:GetAspect( Aspect.Portal ):GetExitFromTag() then
						skip = true
					else
						love.graphics.setColor( 100, 100, 100 )
					end
				else
					love.graphics.setColor( 255, 255, 0 )
				end

				if not skip then
					screen:Rectangle( x, y, sz, sz )
					x = x + sz + margin
					if x >= x2 - margin - 4 then
						x, y = x1 + 4 + margin, y + sz + margin
					end
				end
			end
		end

		if self.x then
			local exit_sz = math.floor( w / 6 ) -- width of exit
			for i, portal in pairs( self.portals ) do
				local exit = portal:GetExitFromTag()
				if exit then
					if portal:GetDest() then
						love.graphics.setColor( table.unpack( map_colour ))
					else
						love.graphics.setColor( 0, 0, 0 )
					end

					local x, y = OffsetExit( self.x, self.y, exit )
					if exit == EXIT.NORTH then
						screen:Rectangle( x1 + (w - exit_sz) / 2, y2 - 4, exit_sz, 4 )
					elseif exit == EXIT.EAST then
						screen:Rectangle( x2 - 4, y1 + (h - exit_sz) / 2, 4, exit_sz )
					elseif exit == EXIT.WEST then
						screen:Rectangle( x1, y1 + (h - exit_sz) / 2, 4, exit_sz )
					elseif exit == EXIT.SOUTH then
						screen:Rectangle( x1 + (w - exit_sz) / 2, y1, exit_sz, 4 )
					end
				end
			end
		end
	end
end

function Location:__tostring()
	return string.format( "[%s]", self:GetTitle())
end


