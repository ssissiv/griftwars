local Zone = class( "Zone", Entity )

function Zone:init( worldgen )
	self.worldgen = worldgen
end

function Zone:OnSpawn( world )
	Entity.OnSpawn( self, world )

	if self.rooms == nil then
		self.rooms = {}
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

function Zone:GeneratePortals( location, new_locations )
	for i, obj in location:Contents() do
		local portal = obj:GetAspect( Aspect.Portal )
		if portal and portal:GetDest() == nil then
			local classes = {}
			recurse_subclasses( Location, function( subclass )
				for j, tag in ipairs( subclass.WORLDGEN_TAGS or table.empty ) do
					if portal:MatchWorldGenTag( tag ) then
						table.insert( classes, subclass )
					end
				end
			end )

			local class = table.arraypick( classes )
			if class then
				-- print( "Match:", location, portal:GetWorldGenTag(), class._classname )
				local new_location = class( self )
				self:SpawnLocation( new_location )

				-- Connect the matching Portal.
				for j, obj2 in new_location:Contents() do
					local portal2 = obj2:GetAspect( Aspect.Portal )
					if portal2 and portal2:GetDest() == nil and portal2:MatchWorldGenTag( portal:GetWorldGenTag() ) then
						portal:Connect( new_location, obj2:GetCoordinate() )
						portal2:Connect( location, obj:GetCoordinate() )
					end
				end

				if new_locations then
					table.insert( new_locations, new_location )
				end

			else
				print( "Could not match portal", location, obj, portal.worldgen_tag )
			end
		end
	end
end

function Zone:SpawnLocation( location )
	location:AssignZone( self )
	self.world:SpawnLocation( location )
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