local Zone = class( "Zone", Entity )

function Zone:init( worldgen, max_depth, origin_portal )
	assert( max_depth )
	assert( origin_portal == nil or is_instance( origin_portal, Aspect.Portal ))
	self.worldgen = worldgen
	self.max_depth = max_depth or 1
	self.origin_portal = origin_portal
end

function Zone:GetName()
	return self.name
end

function Zone:GetMaxDepth()
	return self.max_depth
end

function Zone:OnSpawn( world )
	Entity.OnSpawn( self, world )

	if self.rooms == nil then
		self.rooms = {}
		print( "Zone:OnSpawn", self )
		self:GenerateZone()

		if self.OnGenerateZone then
			self:OnGenerateZone()
		end
	end
end

function Zone:GenerateZone()
	local world = self.world

	local depth = 0

	if self.origin_portal then
		print( "Generating from ", self.origin_portal:GetLocation() )
		self.origin = self:GeneratePortalDest( self.origin_portal, depth )
	else
		local class = self:RandomLocationClass()
		self.origin = class( self )
		self:SpawnLocation( self.origin, depth )
	end

	local locations = { self.origin }
	while #locations > 0 do
		local location = table.remove( locations, 1 )
		self:GeneratePortals( location, locations, location:GetZoneDepth() + 1 )
	end
end

function Zone:GetBounds()
	local x1, y1, x2, y2 = math.huge, math.huge, -math.huge, -math.huge
	for i, room in ipairs( self.rooms ) do
		local x, y = room:GetCoordinate()
		if x and y then
			x1 = math.min( x1, x )
			x2 = math.max( x2, x )
			y1 = math.min( y1, y )
			y2 = math.max( y2, y )
		end
	end

	return x1, y1, x2, y2
end

function Zone:RandomLocationClass( match_tags )
	local classes = {}
	for class, wt in pairs( self.LOCATIONS ) do
		for j, tag in ipairs( class.WORLDGEN_TAGS or table.empty ) do
			if match_tags == nil or WorldGen.MatchWorldGenTag( match_tags, tag ) then
				classes[ class ] = wt
				break
			end
		end
	end

	return self.worldgen:WeightedPick( classes )
end

function Zone:RandomZoneClass()
	return self.worldgen:WeightedPick( self.ZONE_ADJACENCY or table.empty )
end


-- Takes a portal, generates a destination to it.
function Zone:GeneratePortalDest( portal, depth )	
	local class = self:RandomLocationClass( portal:GetWorldGenTag() )
	if class then
		-- print( "Match:", location, portal:GetWorldGenTag(), class._classname )
		local location = portal:GetLocation()
		local new_location = class( self, portal )
		self:SpawnLocation( new_location, depth )

		-- Find and connect the matching Portal.
		for j, obj2 in new_location:Contents() do
			local portal2 = obj2:GetAspect( Aspect.Portal )
			if portal2 and portal2:GetDest() == nil and portal2:MatchWorldGenTag( portal:GetWorldGenTag() ) then
				portal:Connect( new_location, obj2:GetCoordinate() )
				portal2:Connect( location, portal.owner:GetCoordinate() )
				break
			end
		end

		if not portal:GetDest() then
			print( string.format( "Could not connect portal %s -> %s, %s", location ,new_location, portal:GetWorldGenTag() ))
			print( new_location.gen_portal, new_location.gen_portal:GetWorldGenTag() )
			for i, portal in new_location:Portals() do
				print( i, portal, portal:GetWorldGenTag() )
			end
			error( "couldn't connect portal" )
		end

		local exit = portal:GetExitFromTag()
		if exit then
			local wx, wy, wz = portal:GetLocation():GetCoordinate()
			wx, wy = OffsetExit( wx, wy, exit )
			new_location:SetCoordinate( wx, wy, wz )
		end

		return new_location

	else
		print( "Could not match portal", portal:GetLocation(), portal.owner, portal.worldgen_tag )
	end
end

-- Takes a location and attempts to spawn new Locations for each of its disconnected portals.
function Zone:GeneratePortals( location, new_locations, depth )
	if not location:GetCoordinate() then
		location:SetCoordinate( 0, 0, self.world:GetWorldMap():GetMaxDepth() + 1 )
	end

	-- print( "Portals from", location, location:GetCoordinate() )
	for i, obj in location:Contents() do
		local portal = obj:GetAspect( Aspect.Portal )
		if portal and portal:GetDest() == nil and (depth <= self.max_depth or portal:HasWorldGenTag( "entry" )) then
			if not portal:IsExitOccupied() then
				local new_location = self:GeneratePortalDest( portal, depth )
				if new_location then
					table.insert( new_locations, new_location )
				end
			end
		end
	end
end


function Zone:SpawnLocation( location, depth )
	location:AssignZone( self, depth )
	self.world:SpawnLocation( location )
	table.insert( self.rooms, location )
end

function Zone:RandomUnusedPortal( tag )
	local portals = {}
	for i, room in ipairs( self.rooms ) do
		for j, portal in room:Portals() do
			if portal:GetDest() == nil and portal:HasWorldGenTag( tag ) then
				if not portal:IsExitOccupied() then
					table.insert( portals, portal )
				end
			end
		end
	end

	return self.world:ArrayPick( portals )
end

function Zone:RandomRoom()
	return self.worldgen:ArrayPick( self.rooms )
end

function Zone:GetRooms()
	return self.rooms
end

function Zone:RoomAt( i )
	return self.rooms[ i ]
end

function Zone:__tostring()
	return string.format( "[%s | %s]", self._classname, self.name or "" )
end