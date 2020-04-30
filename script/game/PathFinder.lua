local PathFinder = class( "PathFinder" )

function PathFinder:init( source, target )
	self.source = source
	self.target = target
end

-- Generate a path from start_room -> end_room.
-- returns nil if no path can be found (or end_room == start_room),
-- or an array of rooms leading from [start_room, end_room], inclusive.
function PathFinder:CalculatePath()
	local start_room = self:GetStartRoom()
	local end_room = self:GetEndRoom()
	if start_room == end_room then
		return
	end
	local queue = { start_room }
	assert( start_room )
	assert( end_room )
	local from_to = {} -- map of room -> next room back to start
	local path
	local sanity = 0

	while #queue > 0 do
		local room = table.remove( queue, 1 )

		if room == end_room then
			-- Found it! Generate path by walking back to start.
			path = {}
			local i = 0
			while room and i < 20 do
				table.insert( path, room )
				i = i + 1
				room = from_to[ room ]
			end
			table.reverse( path )
			break
		end

		for i, portal in room:Portals() do
			local dest = portal:GetDest()
			-- TODO: can we even path to this portal?
			if dest and from_to[ dest ] == nil and dest ~= start_room then
				assert( dest ~= start_room )
				from_to[ dest ] = room
				table.insert( queue, dest )
			end
		end
		sanity = sanity + 1
		assert( sanity < 1000 )
	end

	return path
end

function PathFinder:GetPath()
	if self.path == nil then
		self.path = self:CalculatePath()

	end

	return self.path
end

function PathFinder:GetStartRoom()
	if is_instance( self.source, Location ) then
		return self.source
	elseif self.source.GetLocation then
		return self.source:GetLocation()
	end
end


function PathFinder:GetEndRoom()
	if is_instance( self.target, Location ) then
		return self.target		
	elseif self.target.GetLocation then
		return self.target:GetLocation()
	else
		error()
	end
end


--------------------------------------------------------------------

local TilePathFinder = class( "TilePathFinder" )

function TilePathFinder:init( actor, source, target )
	assert( actor.location, tostring(actor) )
	self.map = actor.location.map
	assert( is_instance( self.map, Aspect.TileMap ), tostring(actor.location))
	self.actor = actor
	self.source = source
	self.target = target
end

-- Generate a path from start_room -> end_room.
-- returns nil if no path can be found (or end_room == start_room),
-- or an array of rooms leading from [start_room, end_room], inclusive.
function TilePathFinder:CalculatePath()
	local start_room = self:GetStartRoom()
	local end_room = self:GetEndRoom()
	if start_room == end_room then
		return
	end
	local queue = { start_room }
	assert( start_room )
	assert( end_room )
	local from_to = {} -- map of room -> next room back to start
	local path
	local sanity = 0

	while #queue > 0 do
		local room = table.remove( queue, 1 )

		if room == end_room then
			-- Found it! Generate path by walking back to start.
			path = {}
			local i = 0
			while room and i < 20 do
				table.insert( path, room )
				i = i + 1
				room = from_to[ room ]
			end
			table.reverse( path )
			break
		end

		for i, dest in self.map:Neighbours( room ) do
			if from_to[ dest ] == nil and dest ~= start_room and (self.actor == nil or dest:IsPassable( self.actor )) then
				assert( dest ~= start_room )
				from_to[ dest ] = room
				table.insert( queue, dest )
			end
		end
		sanity = sanity + 1
		assert( sanity < 1000 )
	end

	return path
end

function TilePathFinder:GetPath()
	if self.path == nil then
		self.path = self:CalculatePath()
	end

	return self.path
end

function TilePathFinder:GetStartRoom()
	if is_instance( self.source, Agent ) then
		return self.source:GetTile()
	else
		assert( is_instance( self.source, Tile ))
		return self.source
	end
end


function TilePathFinder:GetEndRoom()
	if is_instance( self.target, Agent ) then
		return self.target:GetTile()
	else
		assert( is_instance( self.target, Tile ))
		return self.target
	end
end


