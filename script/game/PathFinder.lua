local PathFinder = class( "PathFinder" )

function PathFinder:init( source, target )
	self.source = source
	self.target = target
end

function PathFinder:CalculatePath()
	local start_room = self:GetStartRoom()
	local end_room = self:GetEndRoom()
	local queue = { start_room }
	assert( start_room )
	assert( end_room )
	local from_to = {} -- map of room -> next room back to start
	local path

	while #queue > 0 do
		local room = table.remove( queue, 1 )

		if room == end_room then
			-- Found it! Generate path by walking back to start.
			path = {}
			local i = 0
			while room and i < 10 do
				table.insert( path, room )
				i = i + 1
				room = from_to[ room ]
			end
			table.reverse( path )
			break
		end

		for i, exit in room:Exits() do
			local dest = exit:GetDest( room )
			if from_to[ dest ] == nil and dest ~= start_room then
				assert( dest ~= start_room )
				from_to[ dest ] = room
				table.insert( queue, dest )
			end
		end
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
	end
end