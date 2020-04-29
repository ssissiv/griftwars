local Zone = class( "Zone", Entity )

function Zone:init( worldgen, max_depth )
	assert( max_depth )
	self.worldgen = worldgen
	self.max_depth = max_depth or 1
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

-- Takes a location and attempts to spawn new Locations for each of its disconnected portals.
function Zone:GeneratePortals( location, new_locations, depth )
	for i, obj in location:Contents() do
		local portal = obj:GetAspect( Aspect.Portal )
		if portal and portal:GetDest() == nil then
			local classes = {}
			for i, subclass in ipairs( self.LOCATIONS ) do
				for j, tag in ipairs( subclass.WORLDGEN_TAGS or table.empty ) do
					if portal:MatchWorldGenTag( tag ) then
						table.insert( classes, subclass )
					end
				end
			end

			local class = table.arraypick( classes )
			if class then
				-- print( "Match:", location, portal:GetWorldGenTag(), class._classname )
				local new_location = class( self, portal )
				self:SpawnLocation( new_location, depth )

				-- Connect the matching Portal.
				for j, obj2 in new_location:Contents() do
					local portal2 = obj2:GetAspect( Aspect.Portal )
					if portal2 and portal2:GetDest() == nil and portal2:MatchWorldGenTag( portal:GetWorldGenTag() ) then
						portal:Connect( new_location, obj2:GetCoordinate() )
						portal2:Connect( location, obj:GetCoordinate() )
						break
					end
				end

				assert( portal:GetDest(), "Could not connect portal", location ,new_location, portal:GetWorldGenTag() )

				if new_locations then
					table.insert( new_locations, new_location )
				end

			else
				print( "Could not match portal", location, obj, portal.worldgen_tag )
			end
		end
	end
end


function Zone:SpawnLocation( location, depth )
	location:AssignZone( self, depth )
	self.world:SpawnLocation( location )
	table.insert( self.rooms, location )
end

function Zone:RandomBoundaryPortal()
	local portals = {}
	for i, room in ipairs( self.rooms ) do
		for j, portal in room:Portals() do
			if portal:GetDest() == nil and portal:HasWorldGenTag( "boundary" ) then
				table.insert( portals, portal )
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